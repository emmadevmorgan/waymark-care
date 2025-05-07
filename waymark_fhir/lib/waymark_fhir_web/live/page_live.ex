defmodule WaymarkFhirWeb.PageLive do
  use WaymarkFhirWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="container mx-auto px-4 py-8">
      <h1 class="text-3xl font-bold mb-8">Welcome to Waymark FHIR Integration</h1>

      <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
        <div class="bg-white rounded-lg shadow p-6">
          <h2 class="text-xl font-semibold mb-4">Waymarkers</h2>
          <p class="text-gray-600 mb-4">
            View and manage care managers and their associated patients and encounters.
          </p>
          <.link
            navigate={~p"/waymarkers"}
            class="inline-block bg-blue-500 text-white px-4 py-2 rounded hover:bg-blue-600"
          >
            View Waymarkers
          </.link>
        </div>

        <div class="bg-white rounded-lg shadow p-6">
          <h2 class="text-xl font-semibold mb-4">FHIR Integration</h2>
          <p class="text-gray-600 mb-4">Monitor FHIR resource processing and data transformation.</p>
          <.link
            navigate={~p"/fhir"}
            class="inline-block bg-green-500 text-white px-4 py-2 rounded hover:bg-green-600"
          >
            View FHIR Status
          </.link>
        </div>
      </div>
    </div>
    """
  end
end
