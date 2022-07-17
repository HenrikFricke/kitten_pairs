defmodule KittenPairs.Game.Round do
  use KittenPairs.Schema
  import Ecto.Changeset

  alias KittenPairs.Game.{Game, Card, Turn, RoundScore}

  schema "rounds" do
    belongs_to :game, Game, foreign_key: :game_id, references: :id
    has_many :cards, Card
    has_many :turns, Turn
    has_many :round_scores, RoundScore
    field :is_completed, :boolean

    timestamps()
  end

  @doc false
  def changeset(round, attrs \\ %{}) do
    round
    |> cast(attrs, [:game_id, :is_completed])
    |> validate_required([:game_id])
  end
end
