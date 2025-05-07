defmodule WaymarkFhir.Encounters.Encounter do
  use Ecto.Schema
  import Ecto.Changeset

  schema "encounters" do
    field :external_identifier, :string
    field :type, :string
    field :status, :string
    field :notes, :string

    belongs_to :patient, WaymarkFhir.Patients.Patient
    belongs_to :waymarker, WaymarkFhir.Waymarkers.Waymarker

    timestamps()
  end

  @doc false
  def changeset(encounter, attrs) do
    encounter
    |> cast(attrs, [:external_identifier, :type, :status, :notes, :patient_id, :waymarker_id])
    |> validate_required([:external_identifier, :type, :status, :patient_id])
    |> unique_constraint(:external_identifier)
    |> foreign_key_constraint(:patient_id)
    |> foreign_key_constraint(:waymarker_id)
  end
end
