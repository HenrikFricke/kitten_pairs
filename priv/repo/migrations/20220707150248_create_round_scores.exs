defmodule KittenPairs.Repo.Migrations.CreateRoundScores do
  use Ecto.Migration

  def change do
    create table(:round_scores) do
      add :score, :integer, default: 0
      add :round_id, references(:rounds, on_delete: :nothing)
      add :player_id, references(:players, on_delete: :nothing)

      timestamps()
    end

    create index(:round_scores, [:round_id])
    create index(:round_scores, [:player_id])
  end
end
