defmodule WaymarkFhirWeb.WaymarkerLive.Index do
  use WaymarkFhirWeb, :live_view

  alias WaymarkFhir.Waymarkers

  @impl true
  def mount(_params, _session, socket) do
    waymarkers = Waymarkers.list_waymarkers()
    {:ok, stream(socket, :waymarkers, waymarkers)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  @impl true
  def handle_info(:refresh, socket) do
    waymarkers = Waymarkers.list_waymarkers()
    {:noreply, stream(socket, :waymarkers, waymarkers, reset: true)}
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Waymarkers")
  end

  defp apply_action(socket, :show, %{"id" => id}) do
    waymarker = Waymarkers.get_waymarker!(id)

    socket
    |> assign(:page_title, "Waymarker Details")
    |> assign(:waymarker, waymarker)
  end
end
