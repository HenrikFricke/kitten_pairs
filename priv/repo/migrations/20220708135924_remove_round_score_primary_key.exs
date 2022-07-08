defmodule KittenPairs.Repo.Migrations.RemoveRoundScorePrimaryKey do
  use Ecto.Migration

  def change do
    drop table(:round_scores)

    drop_if_exists index(:round_scores, [:round_id])
    drop_if_exists index(:round_scores, [:player_id])

    create table(:round_scores, primary_key: false) do
      add :score, :integer, default: 0
      add :round_id, references(:rounds, on_delete: :nothing), primary_key: true
      add :player_id, references(:players, on_delete: :nothing), primary_key: true

      timestamps()
    end

    create(
      unique_index(:round_scores, [:round_id, :player_id], name: :round_id_player_id_unique_index)
    )
  end
end
