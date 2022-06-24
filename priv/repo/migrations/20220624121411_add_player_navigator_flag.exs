defmodule KittenMemory.Repo.Migrations.AddPlayerNavigatorFlag do
  use Ecto.Migration

  def change do
    alter table(:players) do
      add :is_navigator, :boolean, default: false
    end
  end
end
