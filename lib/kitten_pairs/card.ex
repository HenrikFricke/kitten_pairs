defmodule KittenPairs.Card do
  @moduledoc """
  Struct that represents a single card on the board.
  """

  alias __MODULE__

  defstruct id: nil, type: nil, is_visible: false

  def create(type) do
    %Card{id: Ecto.UUID.generate(), type: type}
  end

  def is_match?(%Card{} = card1, %Card{} = card2) when card1.id == card2.id,
    do: raise("Same card identifier")

  def is_match?(%Card{} = card1, %Card{} = card2) when card1.type == card2.type, do: true
  def is_match?(%Card{} = card1, %Card{} = card2) when card1.type != card2.type, do: false
end
