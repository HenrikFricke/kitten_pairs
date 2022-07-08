defmodule KittenPairs.GameTest do
  use KittenPairs.DataCase

  alias KittenPairs.Game

  describe "create_game/1" do
    test "creates a game and player" do
      assert {:ok, %{game: game, player: player}} = Game.create_game("Hen")
      assert Repo.get(Game.Game, game.id)
      assert Repo.get_by(Game.Player, game_id: game.id, id: player.id, is_navigator: true)
    end

    test "fails with long player name" do
      assert {:error, :player, changeset, _game} = Game.create_game("abcdefghi")
      assert %{name: ["should be at most 8 character(s)"]} = errors_on(changeset)
    end

    test "rollbacks game on failure" do
      assert {:error, :player, _changeset, %{game: game}} = Game.create_game("abcdefghi")
      refute Repo.get(Game.Game, game.id)
    end
  end

  describe "join_game/2" do
    test "creates a player" do
      game = insert(:game)
      insert(:player, game_id: game.id)

      assert {:ok, player} = Game.join_game(game.id, "Chi")
      assert Repo.get_by(Game.Player, game_id: game.id, id: player.id, is_navigator: false)
    end

    test "returns an error if game has already enough players" do
      game = insert(:game)
      insert(:player, game_id: game.id)
      insert(:player, game_id: game.id)

      assert {:error, :too_many_players} = Game.join_game(game.id, "Chi")
    end

    test "returns an error if the game is unknown" do
      assert {:error, :unknown_game} = Game.join_game("abc", "Chi")
    end
  end

  describe "get_game_by_id/1" do
    test "returns a game" do
      game = insert(:game)

      assert returned_game = Game.get_game_by_id(game.id)
      assert game.id == returned_game.id
    end

    test "returns nil for unsupported id format" do
      assert Game.get_game_by_id("abc") == nil
    end

    test "returns nil for unknown game" do
      assert Game.get_game_by_id("X8kY6JpsQ5Kgf9fu4uBZ4F") == nil
    end
  end

  describe "create_round/2" do
    test "creates a round" do
      game = insert(:game)
      player = insert(:player)

      assert {:ok, round} = Game.create_round(game.id, player.id)
      assert Repo.get_by(Game.Round, id: round.id, game_id: game.id)
    end

    test "creates cards" do
      game = insert(:game)
      player = insert(:player)

      assert {:ok, round} = Game.create_round(game.id, player.id)
      cards = Repo.all(Game.Card, round_id: round.id)

      assert length(Enum.filter(cards, fn card -> card.type == "kitten0" end)) == 2
      assert length(Enum.filter(cards, fn card -> card.type == "kitten1" end)) == 2
      assert length(Enum.filter(cards, fn card -> card.type == "kitten2" end)) == 2
      assert length(Enum.filter(cards, fn card -> card.type == "kitten3" end)) == 2
      assert length(Enum.filter(cards, fn card -> card.type == "kitten4" end)) == 2
      assert length(Enum.filter(cards, fn card -> card.type == "kitten5" end)) == 2
      assert length(Enum.filter(cards, fn card -> card.type == "kitten6" end)) == 2
      assert length(Enum.filter(cards, fn card -> card.type == "kitten7" end)) == 2
    end

    test "creates a turn" do
      game = insert(:game)
      player = insert(:player)

      assert {:ok, round} = Game.create_round(game.id, player.id)
      assert Repo.get_by(Game.Turn, round_id: round.id, player_id: player.id)
    end
  end

  describe "get_last_round/1" do
    test "returns the last round" do
      game = insert(:game)
      insert(:round, game_id: game.id)
      insert(:round, game_id: game.id)
      round3 = insert(:round, game_id: game.id)

      assert Game.get_last_round(game.id).id == round3.id
    end

    test "returns nil for empty list of rounds" do
      game = insert(:game)

      assert Game.get_last_round(game.id) == nil
    end

    test "preloads cards" do
      game = insert(:game)
      round = insert(:round, game_id: game.id)
      insert(:card, round_id: round.id)

      assert last_round = Game.get_last_round(game.id)
      assert length(last_round.cards) == 1
    end
  end

  describe "complete_turn/1" do
    test "keeps the cards visible if it's a match" do
      game = insert(:game)
      round = insert(:round, game_id: game.id)
      player = insert(:player, game_id: game.id)
      insert(:player, game_id: game.id)
      card1 = insert(:card, round_id: round.id, type: "abc", is_visible: true)
      card2 = insert(:card, round_id: round.id, type: "abc", is_visible: true)
      turn = insert(:turn, round_id: round.id, cards: [card1, card2], player_id: player.id)

      Game.complete_turn(turn.id)

      assert Repo.get_by(Game.Card, id: card1.id, is_visible: true)
      assert Repo.get_by(Game.Card, id: card2.id, is_visible: true)
    end

    test "hides the cards if it's not a match" do
      game = insert(:game)
      round = insert(:round, game_id: game.id)
      player = insert(:player, game_id: game.id)
      insert(:player, game_id: game.id)
      card1 = insert(:card, round_id: round.id, type: "abc", is_visible: true)
      card2 = insert(:card, round_id: round.id, type: "def", is_visible: true)
      turn = insert(:turn, round_id: round.id, cards: [card1, card2], player_id: player.id)

      Game.complete_turn(turn.id)

      assert Repo.get_by(Game.Card, id: card1.id, is_visible: false)
      assert Repo.get_by(Game.Card, id: card2.id, is_visible: false)
    end

    test "creates a new turn if cards available" do
      game = insert(:game)
      round = insert(:round, game_id: game.id)
      player1 = insert(:player, game_id: game.id)
      card1 = insert(:card, round_id: round.id, type: "abc", is_visible: true)
      card2 = insert(:card, round_id: round.id, type: "abc", is_visible: true)
      turn = insert(:turn, round_id: round.id, cards: [card1, card2], player_id: player1.id)

      insert(:player, game_id: game.id)
      insert(:card, round_id: round.id, is_visible: false)
      insert(:card, round_id: round.id, is_visible: false)

      Game.complete_turn(turn.id)

      assert length(Repo.all(Game.Turn, round_id: round.id)) == 2
    end

    test "creates not a new turn if no cards available" do
      game = insert(:game)
      round = insert(:round, game_id: game.id)
      player = insert(:player, game_id: game.id)
      insert(:player, game_id: game.id)
      card1 = insert(:card, round_id: round.id, type: "abc", is_visible: true)
      card2 = insert(:card, round_id: round.id, type: "abc", is_visible: true)
      turn = insert(:turn, round_id: round.id, cards: [card1, card2], player_id: player.id)

      Game.complete_turn(turn.id)

      assert length(Repo.all(Game.Turn, round_id: round.id)) == 1
    end

    test "creates a turn with another player if no match" do
      game = insert(:game)
      round = insert(:round, game_id: game.id)
      player1 = insert(:player, game_id: game.id)
      player2 = insert(:player, game_id: game.id)
      insert(:card, round_id: round.id, is_visible: false)
      insert(:card, round_id: round.id, is_visible: false)
      card1 = insert(:card, round_id: round.id, type: "abc", is_visible: true)
      card2 = insert(:card, round_id: round.id, type: "def", is_visible: true)
      turn = insert(:turn, round_id: round.id, cards: [card1, card2], player_id: player1.id)

      Game.complete_turn(turn.id)

      assert Repo.get_by(Game.Turn, round_id: round.id, player_id: player2.id)
    end

    test "increases the round score if a match" do
      game = insert(:game)
      round = insert(:round, game_id: game.id)
      player = insert(:player, game_id: game.id)
      insert(:player, game_id: game.id)
      card1 = insert(:card, round_id: round.id, type: "abc", is_visible: true)
      card2 = insert(:card, round_id: round.id, type: "abc", is_visible: true)
      turn = insert(:turn, round_id: round.id, cards: [card1, card2], player_id: player.id)
      insert(:round_score, round_id: round.id, player_id: player.id)

      Game.complete_turn(turn.id)

      assert Repo.get_by(Game.RoundScore, round_id: round.id, player_id: player.id).score == 1
    end

    test "keeps the round score if not a match" do
      game = insert(:game)
      round = insert(:round, game_id: game.id)
      player = insert(:player, game_id: game.id)
      insert(:player, game_id: game.id)
      card1 = insert(:card, round_id: round.id, type: "abc", is_visible: true)
      card2 = insert(:card, round_id: round.id, type: "def", is_visible: true)
      turn = insert(:turn, round_id: round.id, cards: [card1, card2], player_id: player.id)
      insert(:round_score, round_id: round.id, player_id: player.id)

      Game.complete_turn(turn.id)

      assert Repo.get_by(Game.RoundScore, round_id: round.id, player_id: player.id).score == 0
    end
  end
end
