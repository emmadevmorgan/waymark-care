defmodule WaymarkFhir.Repo.Migrations.CreateWaymarkers do
  use Ecto.Migration

  def change do
    create table(:waymarkers) do
      add :external_identifier, :string, null: false
      add :first_name, :string, null: false
      add :last_name, :string, null: false
      add :email, :string, null: false
      add :phone_number, :string, null: false
      add :role, :string, null: false
      add :organization_id, references(:organizations, on_delete: :restrict), null: false

      timestamps()
    end

    create unique_index(:waymarkers, [:external_identifier])
    create index(:waymarkers, [:organization_id])
  end
end
