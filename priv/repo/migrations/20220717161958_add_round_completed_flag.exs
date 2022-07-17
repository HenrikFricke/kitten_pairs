defmodule KittenPairs.Repo.Migrations.AddRoundCompletedFlag do
  use Ecto.Migration

  def change do
    alter table(:rounds) do
      add :is_completed, :boolean, default: false
    end
  end
end
