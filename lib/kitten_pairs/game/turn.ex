defmodule KittenPairs.Game.Turn do
  use KittenPairs.Schema
  import Ecto.Changeset

  alias KittenPairs.Game.{Round, Player, Card, TurnCard}

  schema "turns" do
    belongs_to :round, Round
    belongs_to :player, Player
    many_to_many :cards, Card, join_through: TurnCard

    timestamps()
  end

  @doc false
  def changeset(turn, attrs) do
    turn
    |> cast(attrs, [:round_id, :player_id])
    |> validate_required([:round_id, :player_id])
  end
end
