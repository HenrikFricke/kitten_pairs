defmodule KittenMemory.Game.Player do
  use KittenMemory.Schema
  import Ecto.Changeset

  alias KittenMemory.Game.Game

  schema "players" do
    field :name, :string
    field :is_navigator, :boolean
    belongs_to :game, Game, foreign_key: :game_id, references: :id

    timestamps()
  end

  @doc false
  def changeset(player, attrs \\ %{}) do
    player
    |> cast(attrs, [:name, :game_id, :is_navigator])
    |> validate_required([:name])
  end
end
