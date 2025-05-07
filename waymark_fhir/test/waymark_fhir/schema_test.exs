defmodule WaymarkFhir.SchemaTest do
  use WaymarkFhir.DataCase

  alias WaymarkFhir.Organizations.Organization
  alias WaymarkFhir.Waymarkers.Waymarker
  alias WaymarkFhir.Patients.Patient
  alias WaymarkFhir.Encounters.Encounter

  setup do
    # Clean up the database before each test
    Repo.delete_all(Encounter)
    Repo.delete_all(Patient)
    Repo.delete_all(Waymarker)
    Repo.delete_all(Organization)
    :ok
  end

  describe "Organization" do
    test "changeset with valid data" do
      valid_attrs = %{
        external_identifier: "test-org-1",
        name: "Test Hospital",
        org_type: "Healthcare Provider"
      }

      changeset = Organization.changeset(%Organization{}, valid_attrs)
      assert changeset.valid?
    end

    test "changeset with invalid data" do
      invalid_attrs = %{}
      changeset = Organization.changeset(%Organization{}, invalid_attrs)
      refute changeset.valid?
    end

    test "changeset enforces unique external_identifier" do
      {:ok, _org} =
        Repo.insert(%Organization{
          external_identifier: "org_schema_2",
          name: "Test Hospital",
          org_type: "Healthcare Provider"
        })

      changeset =
        Organization.changeset(%Organization{}, %{
          external_identifier: "org_schema_2",
          name: "Another Hospital",
          org_type: "Healthcare Provider"
        })

      assert {:error, changeset} = Repo.insert(changeset)
      assert %{external_identifier: ["has already been taken"]} = errors_on(changeset)
    end
  end

  describe "Waymarker" do
    setup do
      org = organization_fixture()
      %{organization: org}
    end

    test "changeset with valid data", %{organization: org} do
      valid_attrs = %{
        external_identifier: "test-way-1",
        first_name: "John",
        last_name: "Doe",
        role: "Care Manager",
        email: "john.doe@test.com",
        phone_number: "123-456-7890",
        organization_id: org.id
      }

      changeset = Waymarker.changeset(%Waymarker{}, valid_attrs)
      assert changeset.valid?
    end

    test "changeset with invalid data" do
      invalid_attrs = %{}
      changeset = Waymarker.changeset(%Waymarker{}, invalid_attrs)
      refute changeset.valid?
    end
  end

  describe "Patient" do
    setup do
      org = organization_fixture()
      %{organization: org}
    end

    test "changeset with valid data", %{organization: org} do
      valid_attrs = %{
        external_identifier: "test-pat-1",
        first_name: "Jane",
        last_name: "Smith",
        birthday: ~D[1990-01-01],
        organization_id: org.id
      }

      changeset = Patient.changeset(%Patient{}, valid_attrs)
      assert changeset.valid?
    end

    test "changeset with invalid data" do
      invalid_attrs = %{}
      changeset = Patient.changeset(%Patient{}, invalid_attrs)
      refute changeset.valid?
    end

    test "changeset allows optional waymarker_id" do
      {:ok, org} =
        Repo.insert(%Organization{
          external_identifier: "org_schema_5",
          name: "Test Hospital",
          org_type: "Healthcare Provider"
        })

      {:ok, waymarker} =
        Repo.insert(%Waymarker{
          external_identifier: "way_schema_2",
          first_name: "John",
          last_name: "Doe",
          role: "Care Manager",
          email: "john.doe@test.com",
          phone_number: "123-456-7890",
          organization_id: org.id
        })

      valid_attrs = %{
        external_identifier: "pat_schema_2",
        first_name: "Jane",
        last_name: "Smith",
        birthday: ~D[1980-01-01],
        organization_id: org.id,
        waymarker_id: waymarker.id
      }

      changeset = Patient.changeset(%Patient{}, valid_attrs)
      assert changeset.valid?
    end
  end

  describe "Encounter" do
    setup do
      waymarker = waymarker_fixture()
      patient = patient_fixture()
      %{waymarker: waymarker, patient: patient}
    end

    test "changeset with valid data", %{waymarker: waymarker, patient: patient} do
      valid_attrs = %{
        external_identifier: "test-enc-1",
        type: "Initial Visit",
        status: "finished",
        notes: "Initial assessment completed",
        waymarker_id: waymarker.id,
        patient_id: patient.id
      }

      changeset = Encounter.changeset(%Encounter{}, valid_attrs)
      assert changeset.valid?
    end

    test "changeset with invalid data" do
      invalid_attrs = %{}
      changeset = Encounter.changeset(%Encounter{}, invalid_attrs)
      refute changeset.valid?
    end

    test "changeset allows optional notes" do
      {:ok, org} =
        Repo.insert(%Organization{
          external_identifier: "org_schema_7",
          name: "Test Hospital",
          org_type: "Healthcare Provider"
        })

      {:ok, waymarker} =
        Repo.insert(%Waymarker{
          external_identifier: "way_schema_4",
          first_name: "John",
          last_name: "Doe",
          role: "Care Manager",
          email: "john.doe@test.com",
          phone_number: "123-456-7890",
          organization_id: org.id
        })

      {:ok, patient} =
        Repo.insert(%Patient{
          external_identifier: "pat_schema_4",
          first_name: "Jane",
          last_name: "Smith",
          birthday: ~D[1980-01-01],
          organization_id: org.id
        })

      valid_attrs = %{
        external_identifier: "enc_schema_2",
        type: "Initial Visit",
        status: "finished",
        waymarker_id: waymarker.id,
        patient_id: patient.id
      }

      changeset = Encounter.changeset(%Encounter{}, valid_attrs)
      assert changeset.valid?
    end
  end
end
