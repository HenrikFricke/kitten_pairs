defmodule KittenPairs.Repo.Migrations.CleanUpTurnsTable do
  use Ecto.Migration

  def change do
    alter table(:turns) do
      remove_if_exists :first_card, references(:cards, on_delete: :nothing)
      remove_if_exists :second_card, references(:cards, on_delete: :nothing)
    end

    drop_if_exists index(:turns, [:first_card])
    drop_if_exists index(:turns, [:second_card])
  end
end
