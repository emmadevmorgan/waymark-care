defmodule WaymarkFhir.Patients do
  import Ecto.Query
  alias WaymarkFhir.Repo
  alias WaymarkFhir.Patients.Patient

  def list_patients_by_waymarker(waymarker_id) do
    Patient
    |> where([p], p.waymarker_id == ^waymarker_id)
    |> Repo.all()
  end

  def list_patients do
    Patient
    |> order_by([p], [p.last_name, p.first_name])
    |> Repo.all()
  end

  def get_patient!(id) do
    Patient
    |> Repo.get!(id)
    |> Repo.preload([:organization, :encounters])
  end

  def create_patient(attrs \\ %{}) do
    %Patient{}
    |> Patient.changeset(attrs)
    |> Repo.insert()
  end

  def list_patients_by_ids(ids) when is_list(ids) do
    Patient
    |> where([p], p.id in ^ids)
    |> order_by([p], [p.last_name, p.first_name])
    |> Repo.all()
  end
end
