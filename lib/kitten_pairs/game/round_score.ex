defmodule KittenPairs.Game.RoundScore do
  use Ecto.Schema
  use KittenPairs.Schema
  import Ecto.Changeset

  alias KittenPairs.Game.{Round, Player}

  @primary_key false
  schema "round_scores" do
    belongs_to :round, Round
    belongs_to :player, Player
    field :score, :integer

    timestamps()
  end

  @doc false
  def changeset(round_score, attrs) do
    round_score
    |> cast(attrs, [:round, :player, :score])
    |> validate_required([:round, :player, :score])
  end
end
