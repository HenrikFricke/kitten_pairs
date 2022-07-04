defmodule KittenPairs.Game.Turn do
  use KittenPairs.Schema
  import Ecto.Changeset

  alias KittenPairs.Game.{Round, Player}

  schema "turns" do
    belongs_to :round, Round
    belongs_to :player, Player
    field :first_card, :id
    field :second_card, :id

    timestamps()
  end

  @doc false
  def changeset(turn, attrs) do
    turn
    |> cast(attrs, [:round_id, :player_id, :first_card, :second_card])
    |> validate_required([:round_id, :player_id])
  end
end
