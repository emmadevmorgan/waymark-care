defmodule WaymarkFhir.Waymarkers.Waymarker do
  use Ecto.Schema
  import Ecto.Changeset

  schema "waymarkers" do
    field :external_identifier, :string
    field :first_name, :string
    field :last_name, :string
    field :email, :string
    field :phone_number, :string
    field :role, :string

    belongs_to :organization, WaymarkFhir.Organizations.Organization
    has_many :encounters, WaymarkFhir.Encounters.Encounter

    timestamps()
  end

  @doc false
  def changeset(waymarker, attrs) do
    waymarker
    |> cast(attrs, [
      :external_identifier,
      :first_name,
      :last_name,
      :email,
      :phone_number,
      :role,
      :organization_id
    ])
    |> validate_required([
      :external_identifier,
      :first_name,
      :last_name,
      :email,
      :phone_number,
      :role,
      :organization_id
    ])
    |> unique_constraint(:external_identifier)
  end
end
