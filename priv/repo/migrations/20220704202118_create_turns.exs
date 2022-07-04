defmodule KittenPairs.Repo.Migrations.CreateTurns do
  use Ecto.Migration

  def change do
    create table(:turns) do
      add :round_id, references(:rounds, on_delete: :nothing)
      add :player_id, references(:players, on_delete: :nothing)
      add :first_card, references(:cards, on_delete: :nothing)
      add :second_card, references(:cards, on_delete: :nothing)

      timestamps()
    end

    create index(:turns, [:round_id])
    create index(:turns, [:player_id])
    create index(:turns, [:first_card])
    create index(:turns, [:second_card])
  end
end
