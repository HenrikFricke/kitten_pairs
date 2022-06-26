defmodule KittenPairs.Repo.Migrations.UpdatePlayers do
  use Ecto.Migration

  def change do
    alter table(:players) do
      add :game_id, references(:games, on_delete: :nothing)
    end

    create index(:players, [:game_id])
  end
end
