defmodule KittenPairs.Repo.Migrations.CreateRounds do
  use Ecto.Migration

  def change do
    create table(:rounds) do
      add :game_id, references(:games, on_delete: :nothing)

      timestamps()
    end

    create index(:rounds, [:game_id])
  end
end
