defmodule KittenPairs.Repo.Migrations.CreateGames do
  use Ecto.Migration

  def change do
    create table(:games) do
      timestamps()
    end
  end
end
