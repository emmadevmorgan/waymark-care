defmodule WaymarkFhir.Repo.Migrations.CreateOrganizations do
  use Ecto.Migration

  def change do
    create table(:organizations) do
      add :external_identifier, :string, null: false
      add :name, :string, null: false
      add :org_type, :string, null: false

      timestamps()
    end

    create unique_index(:organizations, [:external_identifier])
  end
end
