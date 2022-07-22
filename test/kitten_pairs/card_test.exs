defmodule KittenPairs.CardTest do
  use KittenPairs.DataCase
  alias KittenPairs.Card

  describe "create/0" do
    test "creates unique identifier" do
      assert %{id: id} = Card.create("abc")
      assert id != nil
    end

    test "sets the type" do
      assert %{type: type} = Card.create("abc")
      assert type == "abc"
    end
  end

  describe "is_match?/2" do
    test "is a match" do
      card1 = Card.create("abc")
      card2 = Card.create("abc")

      assert Card.is_match?(card1, card2) == true
    end

    test "is not a match" do
      card1 = Card.create("abc")
      card2 = Card.create("def")

      assert Card.is_match?(card1, card2) == false
    end

    test "raises with the same card" do
      card1 = Card.create("abc")

      assert_raise RuntimeError, "Same card identifier", fn ->
        Card.is_match?(card1, card1)
      end
    end
  end
end
