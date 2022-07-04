defmodule KittenPairs.Game.Round do
  use KittenPairs.Schema
  import Ecto.Changeset

  alias KittenPairs.Game.{Game, Card}

  schema "rounds" do
    belongs_to :game, Game, foreign_key: :game_id, references: :id
    has_many :cards, Card

    timestamps()
  end

  @doc false
  def changeset(round, attrs \\ %{}) do
    round
    |> cast(attrs, [:game_id])
    |> validate_required([:game_id])
  end
end
