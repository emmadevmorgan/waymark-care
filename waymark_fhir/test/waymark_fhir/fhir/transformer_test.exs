defmodule WaymarkFhir.FHIR.TransformerTest do
  use WaymarkFhir.DataCase

  alias WaymarkFhir.FHIR.Transformer
  alias WaymarkFhir.Organizations.Organization
  alias WaymarkFhir.Waymarkers.Waymarker
  alias WaymarkFhir.Patients.Patient
  alias WaymarkFhir.Encounters.Encounter

  describe "transform_organization/1" do
    test "transforms valid organization data" do
      org_data = %{
        "resourceType" => "Organization",
        "id" => "test-org-1",
        "name" => "Test Hospital",
        "type" => [%{"coding" => [%{"display" => "Healthcare Provider"}]}]
      }

      assert {:ok, %Organization{} = org} = Transformer.transform_organization(org_data)
      assert org.external_identifier == "test-org-1"
      assert org.name == "Test Hospital"
      assert org.org_type == "Healthcare Provider"
    end

    test "returns error for invalid organization data" do
      assert {:error, :invalid_organization} = Transformer.transform_organization(%{})
    end
  end

  describe "transform_waymarker/1" do
    setup do
      org = organization_fixture()
      %{organization: org}
    end

    test "transforms valid waymarker data", %{organization: org} do
      waymarker_data = %{
        "resourceType" => "Practitioner",
        "id" => "test-way-1",
        "name" => [%{"family" => "Doe", "given" => ["John"]}],
        "organization" => %{"reference" => "Organization/#{org.external_identifier}"}
      }

      assert {:ok, %Waymarker{} = waymarker} = Transformer.transform_waymarker(waymarker_data)
      assert waymarker.external_identifier == "test-way-1"
      assert waymarker.first_name == "John"
      assert waymarker.last_name == "Doe"
      assert waymarker.organization_id == org.id
    end

    test "returns error for invalid waymarker data" do
      assert {:error, :invalid_waymarker} = Transformer.transform_waymarker(%{})
    end
  end

  describe "transform_patient/1" do
    setup do
      org = organization_fixture()
      %{organization: org}
    end

    test "transforms valid patient data", %{organization: org} do
      patient_data = %{
        "resourceType" => "Patient",
        "id" => "test-pat-1",
        "name" => [%{"family" => "Smith", "given" => ["Jane"]}],
        "managingOrganization" => %{"reference" => "Organization/#{org.external_identifier}"}
      }

      assert {:ok, %Patient{} = patient} = Transformer.transform_patient(patient_data)
      assert patient.external_identifier == "test-pat-1"
      assert patient.first_name == "Jane"
      assert patient.last_name == "Smith"
      assert patient.organization_id == org.id
    end

    test "returns error for invalid patient data" do
      assert {:error, :invalid_patient} = Transformer.transform_patient(%{})
    end
  end

  describe "transform_encounter/1" do
    setup do
      waymarker = waymarker_fixture()
      patient = patient_fixture()
      %{waymarker: waymarker, patient: patient}
    end

    test "transforms valid encounter data", %{waymarker: waymarker, patient: patient} do
      encounter_data = %{
        "resourceType" => "Encounter",
        "id" => "test-enc-1",
        "type" => [%{"coding" => [%{"display" => "Initial Visit"}]}],
        "status" => "finished",
        "participant" => [
          %{"individual" => %{"reference" => "Practitioner/#{waymarker.external_identifier}"}}
        ],
        "subject" => %{"reference" => "Patient/#{patient.external_identifier}"}
      }

      assert {:ok, %Encounter{} = encounter} = Transformer.transform_encounter(encounter_data)
      assert encounter.external_identifier == "test-enc-1"
      assert encounter.type == "Initial Visit"
      assert encounter.status == "finished"
      assert encounter.waymarker_id == waymarker.id
      assert encounter.patient_id == patient.id
    end

    test "returns error for invalid encounter data" do
      assert {:error, :invalid_encounter} = Transformer.transform_encounter(%{})
    end
  end
end
