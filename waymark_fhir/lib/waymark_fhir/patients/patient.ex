defmodule WaymarkFhir.Patients.Patient do
  use Ecto.Schema
  import Ecto.Changeset

  schema "patients" do
    field :external_identifier, :string
    field :first_name, :string
    field :last_name, :string
    field :birthday, :date

    belongs_to :organization, WaymarkFhir.Organizations.Organization
    has_many :encounters, WaymarkFhir.Encounters.Encounter

    timestamps()
  end

  @doc false
  def changeset(patient, attrs) do
    patient
    |> cast(attrs, [:external_identifier, :first_name, :last_name, :birthday, :organization_id])
    |> validate_required([
      :external_identifier,
      :first_name,
      :last_name,
      :birthday,
      :organization_id
    ])
    |> unique_constraint(:external_identifier)
  end
end
