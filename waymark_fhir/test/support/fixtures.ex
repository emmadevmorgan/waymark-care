defmodule WaymarkFhir.QueryFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `WaymarkFhir.Query` context.
  """

  alias WaymarkFhir.Query

  @doc """
  Generate a organization.
  """
  def organization_fixture(attrs \\ %{}) do
    unique_id = System.unique_integer([:positive])

    {:ok, organization} =
      attrs
      |> Enum.into(%{
        name: "Test Hospital",
        external_identifier: "TEST-ORG-#{unique_id}",
        org_type: "Healthcare Provider"
      })
      |> Query.create_organization()

    organization
  end

  @doc """
  Generate a waymarker.
  """
  def waymarker_fixture(attrs \\ %{}) do
    unique_id = System.unique_integer([:positive])
    organization = organization_fixture()

    {:ok, waymarker} =
      attrs
      |> Enum.into(%{
        external_identifier: "TEST-WAY-#{unique_id}",
        first_name: "John",
        last_name: "Doe",
        role: "Care Manager",
        email: "john.doe@test.com",
        phone_number: "123-456-7890",
        organization_id: organization.id
      })
      |> Query.create_waymarker()

    waymarker
  end

  @doc """
  Generate a patient.
  """
  def patient_fixture(attrs \\ %{}) do
    unique_id = System.unique_integer([:positive])
    organization = organization_fixture()

    {:ok, patient} =
      attrs
      |> Enum.into(%{
        external_identifier: "TEST-PAT-#{unique_id}",
        first_name: "Jane",
        last_name: "Smith",
        birthday: ~D[1990-01-01],
        organization_id: organization.id
      })
      |> Query.create_patient()

    patient
  end

  @doc """
  Generate an encounter.
  """
  def encounter_fixture(attrs \\ %{}) do
    unique_id = System.unique_integer([:positive])
    waymarker = waymarker_fixture()
    patient = patient_fixture()

    {:ok, encounter} =
      attrs
      |> Enum.into(%{
        external_identifier: "TEST-ENC-#{unique_id}",
        type: "Initial Visit",
        status: "finished",
        notes: "Initial assessment completed",
        waymarker_id: waymarker.id,
        patient_id: patient.id
      })
      |> Query.create_encounter()

    encounter
  end
end
