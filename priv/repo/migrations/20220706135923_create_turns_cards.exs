defmodule KittenPairs.Repo.Migrations.CreateTurnsCards do
  use Ecto.Migration

  def change do
    create table(:turns_cards, primary_key: false) do
      add :turn_id, references(:turns, on_delete: :delete_all), primary_key: true
      add :card_id, references(:cards, on_delete: :delete_all), primary_key: true

      timestamps()
    end

    create(unique_index(:turns_cards, [:turn_id, :card_id], name: :turn_id_card_id_unique_index))
  end
end
