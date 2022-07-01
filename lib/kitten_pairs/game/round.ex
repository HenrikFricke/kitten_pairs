defmodule KittenPairs.Game.Round do
  use KittenPairs.Schema
  import Ecto.Changeset

  alias KittenPairs.Game.Game

  schema "rounds" do
    belongs_to :game, Game, foreign_key: :game_id, references: :id

    timestamps()
  end

  @doc false
  def changeset(round, attrs \\ %{}) do
    round
    |> cast(attrs, [:game_id])
    |> validate_required([:game_id])
  end
end
