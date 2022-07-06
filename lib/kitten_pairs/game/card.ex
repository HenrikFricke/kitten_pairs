defmodule KittenPairs.Game.Card do
  use KittenPairs.Schema
  import Ecto.Changeset

  alias KittenPairs.Game.{Round, Turn, TurnCard}

  schema "cards" do
    field :is_visible, :boolean, default: false
    field :type, :string
    belongs_to :round, Round, foreign_key: :round_id, references: :id
    many_to_many :turns, Turn, join_through: TurnCard

    timestamps()
  end

  @doc false
  def changeset(card, attrs) do
    card
    |> cast(attrs, [:type, :is_visible, :round_id])
    |> validate_required([:type, :is_visible, :round_id])
  end
end
