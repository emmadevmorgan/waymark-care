defmodule WaymarkFhir.Organizations.Organization do
  use Ecto.Schema
  import Ecto.Changeset

  schema "organizations" do
    field :external_identifier, :string
    field :name, :string
    field :org_type, :string

    has_many :waymarkers, WaymarkFhir.Waymarkers.Waymarker
    has_many :patients, WaymarkFhir.Patients.Patient

    timestamps()
  end

  @doc false
  def changeset(organization, attrs) do
    organization
    |> cast(attrs, [:external_identifier, :name, :org_type])
    |> validate_required([:external_identifier, :name, :org_type])
    |> unique_constraint(:external_identifier)
  end
end
