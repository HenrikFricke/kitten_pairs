defmodule KittenPairs.Card do
  @moduledoc """
  Struct that represents a single card on the board.
  """

  alias __MODULE__

  defstruct type: nil,
            is_visible: false

  def is_match?(%Card{} = card1, %Card{} = card2) when card1.type == card2.type, do: true
  def is_match?(%Card{} = card1, %Card{} = card2) when card1.type != card2.type, do: false
end
