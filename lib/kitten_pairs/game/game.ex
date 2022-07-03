defmodule KittenPairs.Game.Game do
  use KittenPairs.Schema
  import Ecto.Changeset

  alias KittenPairs.Game.{Player, Round}

  schema "games" do
    has_many :players, Player
    has_many :rounds, Round

    timestamps()
  end

  @doc false
  def changeset(game, attrs) do
    game
    |> cast(attrs, [])
    |> validate_required([])
  end
end
