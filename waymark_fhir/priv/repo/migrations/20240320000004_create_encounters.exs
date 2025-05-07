defmodule WaymarkFhir.Repo.Migrations.CreateEncounters do
  use Ecto.Migration

  def change do
    create table(:encounters) do
      add :external_identifier, :string, null: false
      add :type, :string, null: false
      add :status, :string, null: false
      add :notes, :text

      add :waymarker_id, references(:waymarkers, on_delete: :nothing), null: false
      add :patient_id, references(:patients, on_delete: :nothing), null: false

      timestamps()
    end

    create unique_index(:encounters, [:external_identifier])
    create index(:encounters, [:waymarker_id])
    create index(:encounters, [:patient_id])
  end
end
