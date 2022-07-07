defmodule KittenPairs.Game.Player do
  use KittenPairs.Schema
  import Ecto.Changeset

  alias KittenPairs.Game.Game

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
    |> validate_length(:name, max: 8)
  end
end
