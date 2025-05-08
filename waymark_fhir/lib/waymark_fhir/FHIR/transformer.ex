defmodule WaymarkFhir.FHIR.Transformer do
  @moduledoc """
  Transforms FHIR resources into our internal schema.
  """

  require Logger
  alias WaymarkFhir.Organizations.Organization
  alias WaymarkFhir.Waymarkers.Waymarker
  alias WaymarkFhir.Patients.Patient
  alias WaymarkFhir.Encounters.Encounter
  alias WaymarkFhir.Repo

  @doc """
  Transforms a FHIR resource into our internal schema.
  """
  def transform(%{"resourceType" => "Organization"} = resource) do
    transform_organization(resource)
  end

  def transform(%{"resourceType" => "Practitioner"} = resource) do
    transform_waymarker(resource)
  end

  def transform(%{"resourceType" => "Patient"} = resource) do
    transform_patient(resource)
  end

  def transform(%{"resourceType" => "Encounter"} = resource) do
    transform_encounter(resource)
  end

  def transform(_) do
    {:error, :invalid_resource_type}
  end

  @doc """
  Transforms a FHIR Organization resource into our internal schema.
  """
  def transform_organization(%{
        "id" => id,
        "name" => name,
        "type" => [%{"coding" => [%{"display" => org_type}]}]
      }) do
    {:ok,
     %Organization{
       external_identifier: id,
       name: name,
       org_type: org_type
     }}
  end

  def transform_organization(_), do: {:error, :invalid_organization}

  @doc """
  Transforms a FHIR Practitioner resource into our internal schema.
  """
  def transform_waymarker(
        %{"id" => id, "name" => [%{"family" => last_name, "given" => [first_name | _]}]} = data
      ) do
    with {:ok, org_id} <- extract_organization_id(data),
         org when not is_nil(org) <- Repo.get_by(Organization, external_identifier: org_id) do
      {:ok,
       %Waymarker{
         external_identifier: id,
         first_name: first_name,
         last_name: last_name,
         role: extract_role(data),
         email: extract_email(data),
         phone_number: extract_phone(data),
         organization_id: org.id
       }}
    else
      nil -> {:error, :organization_not_found}
      error -> error
    end
  end

  def transform_waymarker(_), do: {:error, :invalid_waymarker}

  @doc """
  Transforms a FHIR Patient resource into our internal schema.
  """
  def transform_patient(
        %{"id" => id, "name" => [%{"family" => last_name, "given" => [first_name | _]}]} = data
      ) do
    with {:ok, org_id} <- extract_organization_id(data),
         org when not is_nil(org) <- Repo.get_by(Organization, external_identifier: org_id) do
      {:ok,
       %Patient{
         external_identifier: id,
         first_name: first_name,
         last_name: last_name,
         birthday: extract_birthday(data),
         organization_id: org.id
       }}
    else
      nil -> {:error, :organization_not_found}
      error -> error
    end
  end

  def transform_patient(_), do: {:error, :invalid_patient}

  @doc """
  Transforms a FHIR Encounter resource into our internal schema.
  """
  def transform_encounter(%{"id" => id} = data) do
    Logger.info("Transforming encounter: #{inspect(data)}")

    type = extract_encounter_type(data)

    if is_nil(type) do
      Logger.error("Encounter type is missing for resource: #{inspect(data)}")
      {:error, :missing_encounter_type}
    else
      with {:ok, waymarker_id, patient_id} <- extract_participants(data),
           _ =
             Logger.info(
               "Found participants - waymarker: #{waymarker_id}, patient: #{patient_id}"
             ),
           waymarker when not is_nil(waymarker) <-
             Repo.get_by(Waymarker, external_identifier: waymarker_id),
           _ = Logger.info("Found waymarker: #{inspect(waymarker)}"),
           patient when not is_nil(patient) <-
             Repo.get_by(Patient, external_identifier: patient_id),
           _ = Logger.info("Found patient: #{inspect(patient)}") do
        encounter = %Encounter{
          external_identifier: id,
          type: type,
          status: extract_encounter_status(data),
          notes: extract_encounter_notes(data),
          waymarker_id: waymarker.id,
          patient_id: patient.id
        }

        Logger.info("Created encounter: #{inspect(encounter)}")
        {:ok, encounter}
      else
        nil ->
          Logger.error("Failed to find waymarker or patient")
          {:error, :participant_not_found}

        error ->
          Logger.error("Error transforming encounter: #{inspect(error)}")
          error
      end
    end
  end

  def transform_encounter(_), do: {:error, :invalid_encounter}

  # Helper functions for extracting data from FHIR resources

  defp extract_organization_id(%{"organization" => %{"reference" => "Organization/" <> id}}),
    do: {:ok, id}

  defp extract_organization_id(%{
         "managingOrganization" => %{"reference" => "Organization/" <> id}
       }),
       do: {:ok, id}

  defp extract_organization_id(%{"organization" => %{"reference" => ref}}) do
    Logger.warning("Invalid organization reference format: #{ref}")
    {:error, :invalid_organization_reference}
  end

  defp extract_organization_id(%{"managingOrganization" => %{"reference" => ref}}) do
    Logger.warning("Invalid organization reference format: #{ref}")
    {:error, :invalid_organization_reference}
  end

  defp extract_organization_id(_), do: {:error, :missing_organization}

  defp extract_role(%{"qualification" => [%{"code" => %{"coding" => [%{"display" => role}]}}]}),
    do: role

  defp extract_role(_), do: nil

  defp extract_email(%{"telecom" => telecom}) do
    Enum.find_value(telecom, fn
      %{"system" => "email", "value" => email} -> email
      _ -> nil
    end)
  end

  defp extract_email(_), do: nil

  defp extract_phone(%{"telecom" => telecom}) do
    Enum.find_value(telecom, fn
      %{"system" => "phone", "value" => phone} -> phone
      _ -> nil
    end)
  end

  defp extract_phone(_), do: nil

  defp extract_birthday(%{"birthDate" => date}), do: Date.from_iso8601!(date)
  defp extract_birthday(_), do: nil

  defp extract_participants(%{
         "participant" => participants,
         "subject" => %{"reference" => "Patient/" <> patient_id}
       }) do
    Logger.info("Extracting participants with subject: #{patient_id}")

    case Enum.find_value(participants, fn
           %{"actor" => %{"reference" => "Practitioner/" <> practitioner_id}} ->
             practitioner_id

           %{"individual" => %{"reference" => "Practitioner/" <> practitioner_id}} ->
             practitioner_id

           _ ->
             nil
         end) do
      nil -> {:error, :missing_practitioner}
      practitioner_id -> {:ok, practitioner_id, patient_id}
    end
  end

  defp extract_participants(_), do: {:error, :invalid_participants}

  defp extract_encounter_type(%{"type" => [%{"coding" => [%{"display" => type}]}]}), do: type
  defp extract_encounter_type(%{"class" => %{"display" => type}}), do: type
  defp extract_encounter_type(_), do: nil

  defp extract_encounter_status(%{"status" => status}), do: status
  defp extract_encounter_status(_), do: nil

  defp extract_encounter_notes(%{"text" => %{"div" => note}}) do
    note
    |> String.replace(~r/<[^>]*>/, "")
    |> String.trim()
  end

  defp extract_encounter_notes(%{"note" => [%{"text" => note}]}), do: note
  defp extract_encounter_notes(_), do: nil
end
