defmodule WaymarkFhir.Query do
  @moduledoc """
  Provides query functions for interacting with the database.
  """

  import Ecto.Query
  alias WaymarkFhir.Repo
  alias WaymarkFhir.Organizations.Organization
  alias WaymarkFhir.Waymarkers.Waymarker
  alias WaymarkFhir.Patients.Patient
  alias WaymarkFhir.Encounters.Encounter
  require Logger

  @doc """
  Lists all organizations.
  """
  def list_organizations do
    Repo.all(Organization)
  end

  @doc """
  Gets a single organization by ID.
  """
  def get_organization!(id), do: Repo.get!(Organization, id)

  @doc """
  Gets a single organization by ID, returns nil if not found.
  """
  def get_organization(id), do: Repo.get(Organization, id)

  @doc """
  Creates an organization.
  """
  def create_organization(attrs \\ %{}) do
    %Organization{}
    |> Organization.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Lists all waymarkers.
  """
  def list_waymarkers do
    Repo.all(Waymarker)
  end

  @doc """
  Gets a single waymarker by ID.
  """
  def get_waymarker!(id), do: Repo.get!(Waymarker, id)

  @doc """
  Gets a single waymarker by ID, returns nil if not found.
  """
  def get_waymarker(id), do: Repo.get(Waymarker, id)

  @doc """
  Gets a single waymarker by ID with preloaded organization and encounters, returns nil if not found.
  """
  def get_waymarker_with_org(id) do
    Waymarker
    |> where([w], w.id == ^id)
    |> preload([:organization, :encounters])
    |> Repo.one()
  end

  @doc """
  Creates a waymarker.
  """
  def create_waymarker(attrs \\ %{}) do
    %Waymarker{}
    |> Waymarker.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Lists all patients.
  """
  def list_patients do
    Repo.all(Patient)
  end

  @doc """
  Lists all patients for a given waymarker.
  """
  def list_patients_by_waymarker(waymarker_id) do
    Patient
    |> where([p], p.waymarker_id == ^waymarker_id)
    |> Repo.all()
  end

  @doc """
  Gets a patient by ID.
  """
  def get_patient!(id), do: Repo.get!(Patient, id)

  @doc """
  Gets a patient by ID, returns nil if not found.
  """
  def get_patient(id), do: Repo.get(Patient, id)

  @doc """
  Creates a patient.
  """
  def create_patient(attrs \\ %{}) do
    %Patient{}
    |> Patient.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Lists all encounters.
  """
  def list_encounters do
    Repo.all(Encounter)
  end

  @doc """
  Lists all encounters for a given waymarker.
  """
  def list_encounters_by_waymarker(waymarker_id) do
    Encounter
    |> where([e], e.waymarker_id == ^waymarker_id)
    |> Repo.all()
  end

  @doc """
  Gets an encounter by ID.
  """
  def get_encounter!(id), do: Repo.get!(Encounter, id)

  @doc """
  Gets an encounter by ID, returns nil if not found.
  """
  def get_encounter(id), do: Repo.get(Encounter, id)

  @doc """
  Creates an encounter.
  """
  def create_encounter(attrs \\ %{}) do
    %Encounter{}
    |> Encounter.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Creates or updates a record based on the transformed data.
  """
  def create_or_update_record(%Organization{} = org) do
    case Repo.get_by(Organization, external_identifier: org.external_identifier) do
      nil ->
        %Organization{}
        |> Organization.changeset(Map.from_struct(org))
        |> Repo.insert()

      existing_org ->
        {:ok, existing_org}
    end
  end

  def create_or_update_record(%Waymarker{} = waymarker) do
    case Repo.get_by(Waymarker, external_identifier: waymarker.external_identifier) do
      nil ->
        %Waymarker{}
        |> Waymarker.changeset(Map.from_struct(waymarker))
        |> Repo.insert()

      existing_waymarker ->
        {:ok, existing_waymarker}
    end
  end

  def create_or_update_record(%Patient{} = patient) do
    case Repo.get_by(Patient, external_identifier: patient.external_identifier) do
      nil ->
        %Patient{}
        |> Patient.changeset(Map.from_struct(patient))
        |> Repo.insert()

      existing_patient ->
        {:ok, existing_patient}
    end
  end

  def create_or_update_record(%Encounter{} = encounter) do
    case Repo.get_by(Encounter, external_identifier: encounter.external_identifier) do
      nil ->
        %Encounter{}
        |> Encounter.changeset(Map.from_struct(encounter))
        |> Repo.insert()

      existing_encounter ->
        {:ok, existing_encounter}
    end
  end
end
