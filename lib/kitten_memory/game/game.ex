defmodule KittenMemory.Game.Game do
  use KittenMemory.Schema
  import Ecto.Changeset

  alias KittenMemory.Game.Player

  schema "games" do
    has_many :players, Player

    timestamps()
  end

  @doc false
  def changeset(game, attrs) do
    game
    |> cast(attrs, [])
    |> validate_required([])
  end
end
