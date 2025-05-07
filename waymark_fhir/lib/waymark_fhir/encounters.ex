defmodule WaymarkFhir.Encounters do
  import Ecto.Query
  alias WaymarkFhir.Repo
  alias WaymarkFhir.Encounters.Encounter

  def list_encounters_by_waymarker(waymarker_id) do
    Encounter
    |> where([e], e.waymarker_id == ^waymarker_id)
    |> Repo.all()
  end
end
