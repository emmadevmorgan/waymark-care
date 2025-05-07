defmodule WaymarkFhirWeb.FhirLive.Index do
  use WaymarkFhirWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="container mx-auto px-4 py-8">
      <div class="mb-8">
        <.link navigate={~p"/"} class="text-indigo-600 hover:text-indigo-800">
          ← Back to Home
        </.link>
      </div>

      <h1 class="text-3xl font-bold mb-8">FHIR Integration Status</h1>

      <div class="bg-white shadow rounded-lg p-6">
        <h2 class="text-xl font-semibold mb-4">RabbitMQ Queue Status</h2>
        <p class="text-gray-600">
          The FHIR integration service is actively monitoring the RabbitMQ queue for incoming FHIR resources.
        </p>
      </div>
    </div>
    """
  end
end
