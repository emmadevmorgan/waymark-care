defmodule WaymarkFhir.QueryTest do
  use WaymarkFhir.DataCase

  alias WaymarkFhir.Query
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

  describe "organizations" do
    test "list_organizations/0 returns all organizations" do
      organization = organization_fixture()
      assert Query.list_organizations() == [organization]
    end

    test "get_organization!/1 returns the organization with given id" do
      organization = organization_fixture()
      assert Query.get_organization!(organization.id) == organization
    end

    test "create_organization/1 with valid data creates an organization" do
      valid_attrs = %{
        external_identifier: "test-org-1",
        name: "Test Hospital",
        org_type: "Healthcare Provider"
      }

      assert {:ok, %Organization{} = organization} = Query.create_organization(valid_attrs)
      assert organization.external_identifier == "test-org-1"
      assert organization.name == "Test Hospital"
      assert organization.org_type == "Healthcare Provider"
    end

    test "create_organization/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Query.create_organization(%{})
    end
  end

  describe "waymarkers" do
    setup do
      org = organization_fixture()
      %{organization: org}
    end

    test "list_waymarkers/0 returns all waymarkers" do
      waymarker = waymarker_fixture()
      assert Query.list_waymarkers() == [waymarker]
    end

    test "get_waymarker!/1 returns the waymarker with given id" do
      waymarker = waymarker_fixture()
      assert Query.get_waymarker!(waymarker.id) == waymarker
    end

    test "create_waymarker/1 with valid data creates a waymarker", %{organization: org} do
      valid_attrs = %{
        external_identifier: "test-way-1",
        first_name: "John",
        last_name: "Doe",
        role: "Care Manager",
        email: "john.doe@test.com",
        phone_number: "123-456-7890",
        organization_id: org.id
      }

      assert {:ok, %Waymarker{} = waymarker} = Query.create_waymarker(valid_attrs)
      assert waymarker.external_identifier == "test-way-1"
      assert waymarker.first_name == "John"
      assert waymarker.last_name == "Doe"
      assert waymarker.role == "Care Manager"
      assert waymarker.email == "john.doe@test.com"
      assert waymarker.phone_number == "123-456-7890"
      assert waymarker.organization_id == org.id
    end

    test "create_waymarker/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Query.create_waymarker(%{})
    end
  end

  describe "patients" do
    setup do
      org = organization_fixture()
      %{organization: org}
    end

    test "list_patients/0 returns all patients" do
      patient = patient_fixture()
      assert Query.list_patients() == [patient]
    end

    test "get_patient!/1 returns the patient with given id" do
      patient = patient_fixture()
      assert Query.get_patient!(patient.id) == patient
    end

    test "create_patient/1 with valid data creates a patient", %{organization: org} do
      valid_attrs = %{
        external_identifier: "test-pat-1",
        first_name: "Jane",
        last_name: "Smith",
        birthday: ~D[1990-01-01],
        organization_id: org.id
      }

      assert {:ok, %Patient{} = patient} = Query.create_patient(valid_attrs)
      assert patient.external_identifier == "test-pat-1"
      assert patient.first_name == "Jane"
      assert patient.last_name == "Smith"
      assert patient.birthday == ~D[1990-01-01]
      assert patient.organization_id == org.id
    end

    test "create_patient/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Query.create_patient(%{})
    end
  end

  describe "encounters" do
    setup do
      waymarker = waymarker_fixture()
      patient = patient_fixture()
      %{waymarker: waymarker, patient: patient}
    end

    test "list_encounters/0 returns all encounters" do
      encounter = encounter_fixture()
      assert Query.list_encounters() == [encounter]
    end

    test "get_encounter!/1 returns the encounter with given id" do
      encounter = encounter_fixture()
      assert Query.get_encounter!(encounter.id) == encounter
    end

    test "list_encounters_by_waymarker/1 returns all encounters for a waymarker" do
      waymarker = waymarker_fixture()
      encounter = encounter_fixture(%{waymarker_id: waymarker.id})
      assert Query.list_encounters_by_waymarker(waymarker.id) == [encounter]
    end

    test "create_encounter/1 with valid data creates an encounter", %{
      waymarker: waymarker,
      patient: patient
    } do
      valid_attrs = %{
        external_identifier: "test-enc-1",
        type: "Initial Visit",
        status: "finished",
        notes: "Initial assessment completed",
        waymarker_id: waymarker.id,
        patient_id: patient.id
      }

      assert {:ok, %Encounter{} = encounter} = Query.create_encounter(valid_attrs)
      assert encounter.external_identifier == "test-enc-1"
      assert encounter.type == "Initial Visit"
      assert encounter.status == "finished"
      assert encounter.notes == "Initial assessment completed"
      assert encounter.waymarker_id == waymarker.id
      assert encounter.patient_id == patient.id
    end

    test "create_encounter/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Query.create_encounter(%{})
    end
  end
end
