defmodule WaymarkFhirWeb.Live.WayMarkerLiveTest do
    use WaymarkFhirWeb.ConnCase
  
    alias WaymarkFhir.Organizations.Organization
    alias WaymarkFhir.Repo
  
    setup do
      # Create a test organization
      {:ok, org} = Repo.insert(%Organization{
        external_identifier: "test-org-1",
        name: "Test Organization",
        org_type: "healthcare_provider"
      })
  
      {:ok, %{organization: org}}
    end
  
    describe "Browser Routes" do
      test "GET /", %{conn: conn} do
        conn = get(conn, "/")
        assert html_response(conn, 200) =~ "Welcome to Waymark FHIR"
      end
  
      test "GET /waymarkers", %{conn: conn} do
        conn = get(conn, "/waymarkers")
        assert html_response(conn, 200) =~ "Waymarkers"
      end
  
      test "GET /waymarkers/:id", %{conn: conn, organization: org} do
        # Create a test waymarker
        {:ok, waymarker} = WaymarkFhir.Query.create_or_update_record(%WaymarkFhir.Waymarkers.Waymarker{
          external_identifier: "test-123",
          first_name: "Test",
          last_name: "Waymarker",
          email: "test@example.com",
          phone_number: "123-456-7890",
          role: "care_manager",
          organization_id: org.id
        })
  
        conn = get(conn, "/waymarkers/#{waymarker.id}")
        assert html_response(conn, 200) =~ "Test Waymarker"
      end
  
      test "GET /fhir", %{conn: conn} do
        conn = get(conn, "/fhir")
        assert html_response(conn, 200) =~ "FHIR Integration Status"
      end
    end
  
    describe "Error Handling" do
      test "GET /waymarkers/:id with invalid id", %{conn: conn} do
        conn = get(conn, "/waymarkers/999999")
        assert html_response(conn, 302)
        assert get_flash(conn, :error) == "Waymarker not found"
        assert redirected_to(conn) == "/waymarkers"
      end
  
      test "GET /invalid-route", %{conn: conn} do
        conn = get(conn, "/invalid-route")
        assert html_response(conn, 404) =~ "Not Found"
      end
    end
  
    describe "LiveView Routes" do
      test "LiveView /waymarkers", %{conn: conn} do
        {:ok, view, _html} = live(conn, "/waymarkers")
        assert has_element?(view, "h1", "Waymarkers")
      end
  
      test "LiveView /waymarkers/:id", %{conn: conn, organization: org} do
        # Create a test waymarker
        {:ok, waymarker} = WaymarkFhir.Query.create_or_update_record(%WaymarkFhir.Waymarkers.Waymarker{
          external_identifier: "test-456",
          first_name: "Test",
          last_name: "Waymarker",
          email: "test@example.com",
          phone_number: "123-456-7890",
          role: "care_manager",
          organization_id: org.id
        })
  
        {:ok, view, _html} = live(conn, "/waymarkers/#{waymarker.id}")
        assert has_element?(view, "h2", "Waymarker Details")
      end
  
      test "LiveView /fhir", %{conn: conn} do
        {:ok, view, _html} = live(conn, "/fhir")
        assert has_element?(view, "h1", "FHIR Integration Status")
      end
    end
  
    describe "LiveView Interactions" do
      test "Waymarker list updates", %{conn: conn, organization: org} do
        {:ok, view, _html} = live(conn, "/waymarkers")
        
        # Create a new waymarker
        {:ok, waymarker} = WaymarkFhir.Query.create_or_update_record(%WaymarkFhir.Waymarkers.Waymarker{
          external_identifier: "test-789",
          first_name: "New",
          last_name: "Waymarker",
          email: "new@example.com",
          phone_number: "987-654-3210",
          role: "care_manager",
          organization_id: org.id
        })
  
        # Refresh the page
        send(view.pid, :refresh)
        assert has_element?(view, "td div.text-sm.font-medium.text-gray-900", "#{waymarker.first_name} #{waymarker.last_name}")
        assert has_element?(view, "td div.text-sm.text-gray-900", waymarker.role)
        assert has_element?(view, "td div.text-sm.text-gray-500", waymarker.email)
      end
  
      test "Waymarker details show encounters", %{conn: conn, organization: org} do
        # Create a test waymarker
        {:ok, waymarker} = WaymarkFhir.Query.create_or_update_record(%WaymarkFhir.Waymarkers.Waymarker{
          external_identifier: "test-101",
          first_name: "Test",
          last_name: "Waymarker",
          email: "test@example.com",
          phone_number: "123-456-7890",
          role: "care_manager",
          organization_id: org.id
        })
  
        # Create a test patient
        {:ok, patient} = WaymarkFhir.Query.create_or_update_record(%WaymarkFhir.Patients.Patient{
          external_identifier: "test-pat-101",
          first_name: "John",
          last_name: "Doe",
          birthday: ~D[1980-01-01],
          organization_id: org.id
        })
  
        # Create a test encounter
        {:ok, _encounter} = WaymarkFhir.Query.create_or_update_record(%WaymarkFhir.Encounters.Encounter{
          external_identifier: "test-enc-101",
          waymarker_id: waymarker.id,
          patient_id: patient.id,
          status: "completed",
          type: "initial_assessment",
          notes: "Initial assessment completed"
        })
  
        {:ok, view, _html} = live(conn, "/waymarkers/#{waymarker.id}")
        assert has_element?(view, "h3", "Encounters")
        assert has_element?(view, "div", "initial_assessment")
      end
    end
  end 