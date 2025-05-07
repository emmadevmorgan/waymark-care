defmodule WaymarkFhir.Repo.Migrations.CreatePatients do
  use Ecto.Migration

  def change do
    create table(:patients) do
      add :external_identifier, :string, null: false
      add :first_name, :string, null: false
      add :last_name, :string, null: false
      add :birthday, :date, null: false
      add :organization_id, references(:organizations, on_delete: :nothing), null: false
      add :waymarker_id, references(:waymarkers, on_delete: :nothing)

      timestamps()
    end

    create unique_index(:patients, [:external_identifier])
    create index(:patients, [:organization_id])
    create index(:patients, [:waymarker_id])
  end
end
