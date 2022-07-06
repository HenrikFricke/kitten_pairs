defmodule KittenPairs.Game.TurnCard do
  use KittenPairs.Schema
  import Ecto.Changeset

  alias KittenPairs.Game.{Turn, Card}

  @primary_key false
  schema "turns_cards" do
    belongs_to :turn, Turn, foreign_key: :turn_id, references: :id
    belongs_to :card, Card, foreign_key: :card_id, references: :id

    timestamps()
  end

  @doc false
  def changeset(turn_card, attrs) do
    turn_card
    |> cast(attrs, [])
    |> validate_required([])
  end
end
