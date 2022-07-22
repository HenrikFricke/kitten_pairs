defmodule KittenPairs.GameStateTest do
  use KittenPairs.DataCase
  alias KittenPairs.GameState

  setup do
    %{game_id: "ABCD", p1: build(:player2), p2: build(:player2)}
  end

  describe "new/2" do
    test "creates game state with id", %{game_id: game_id, p1: p1} do
      assert %{id: id} = GameState.new(game_id, p1)
      assert id == game_id
    end

    test "sets first player to navigator", %{game_id: game_id, p1: p1} do
      assert %{players: [player1]} = GameState.new(game_id, p1)
      assert player1.is_navigator
    end
  end

  describe "join/2" do
    test "appends the player", %{game_id: game_id, p1: p1, p2: p2} do
      state = GameState.new(game_id, p1)

      assert {:ok, state} = GameState.join(state, p2)
      assert length(state.players) == 2
    end

    test "too many players", %{game_id: game_id, p1: p1, p2: p2} do
      p3 = build(:player2)

      {:ok, state} =
        GameState.new(game_id, p1)
        |> GameState.join(p2)

      assert {:error, :too_many_players} = GameState.join(state, p3)
    end
  end

  describe "start/1" do
    test "picks player for first turn", %{game_id: game_id, p1: p1, p2: p2} do
      {:ok, state} =
        GameState.new(game_id, p1)
        |> GameState.join(p2)

      assert %{player_turn: player_turn} = GameState.start(state)
      assert player_turn != nil
    end

    test "updates the status", %{game_id: game_id, p1: p1, p2: p2} do
      {:ok, state} =
        GameState.new(game_id, p1)
        |> GameState.join(p2)

      assert %{status: status} = GameState.start(state)
      assert status == :playing
    end

    test "creates cards", %{game_id: game_id, p1: p1, p2: p2} do
      {:ok, state} =
        GameState.new(game_id, p1)
        |> GameState.join(p2)

      assert %{cards: cards} = GameState.start(state)

      assert length(Enum.filter(cards, fn card -> card.type == "kitten0" end)) == 2
      assert length(Enum.filter(cards, fn card -> card.type == "kitten1" end)) == 2
      assert length(Enum.filter(cards, fn card -> card.type == "kitten2" end)) == 2
      assert length(Enum.filter(cards, fn card -> card.type == "kitten3" end)) == 2
      assert length(Enum.filter(cards, fn card -> card.type == "kitten4" end)) == 2
      assert length(Enum.filter(cards, fn card -> card.type == "kitten5" end)) == 2
      assert length(Enum.filter(cards, fn card -> card.type == "kitten6" end)) == 2
      assert length(Enum.filter(cards, fn card -> card.type == "kitten7" end)) == 2
    end
  end
end
