defmodule WaymarkFhir.Waymarkers do
  import Ecto.Query
  alias WaymarkFhir.Repo
  alias WaymarkFhir.Waymarkers.Waymarker

  def list_waymarkers do
    Waymarker
    |> order_by([w], [w.last_name, w.first_name])
    |> preload(:organization)
    |> Repo.all()
  end

  def get_waymarker!(id) do
    Waymarker
    |> Repo.get!(id)
    |> Repo.preload([:organization, :encounters])
  end

  def create_waymarker(attrs \\ %{}) do
    %Waymarker{}
    |> Waymarker.changeset(attrs)
    |> Repo.insert()
  end
end
