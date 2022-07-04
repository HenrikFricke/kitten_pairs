defmodule KittenPairs.Repo.Migrations.CreateCards do
  use Ecto.Migration

  def change do
    create table(:cards) do
      add :type, :string
      add :is_visible, :boolean, default: false, null: false
      add :round_id, references(:rounds, on_delete: :nothing)

      timestamps(type: :utc_datetime_usec)
    end

    create index(:cards, [:round_id])
  end
end
