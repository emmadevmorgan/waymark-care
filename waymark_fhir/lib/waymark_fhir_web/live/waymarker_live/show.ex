defmodule WaymarkFhirWeb.WaymarkerLive.Show do
  use WaymarkFhirWeb, :live_view

  alias WaymarkFhir.Query
  alias WaymarkFhir.Patients
  alias WaymarkFhir.Encounters

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _url, socket) do
    case Query.get_waymarker_with_org(id) do
      nil ->
        {:noreply,
         socket
         |> put_flash(:error, "Waymarker not found")
         |> redirect(to: ~p"/waymarkers")}

      waymarker ->
        encounters = Encounters.list_encounters_by_waymarker(waymarker.id)
        patient_ids = Enum.map(encounters, & &1.patient_id)
        related_patients = Patients.list_patients_by_ids(patient_ids)

        {:noreply,
         socket
         |> assign(:page_title, "Waymarker Details")
         |> assign(:waymarker, waymarker)
         |> assign(:related_patients, related_patients)
         |> assign(:related_encounters, encounters)}
    end
  end
end
