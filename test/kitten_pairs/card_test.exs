defmodule KittenPairs.CardTest do
  use KittenPairs.DataCase
  alias KittenPairs.Card

  describe "is_match?/2" do
    test "is a match" do
      card1 = %Card{type: "abc"}
      card2 = %Card{type: "abc"}

      assert Card.is_match?(card1, card2) == true
    end

    test "is not a match" do
      card1 = %Card{type: "abc"}
      card2 = %Card{type: "def"}

      assert Card.is_match?(card1, card2) == false
    end
  end
end
