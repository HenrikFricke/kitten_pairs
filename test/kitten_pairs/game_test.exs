defmodule KittenPairs.GameTest do
  use KittenPairs.DataCase

  alias KittenPairs.Game

  setup do
    {:ok, game} = Repo.insert(%Game.Game{})

    %{game: game}
  end

  describe "create_game/1" do
    test "creates a game and player" do
      {:ok, game, player} = Game.create_game("Chi")

      assert Repo.exists?(from g in Game.Game, where: g.id == ^game.id)

      assert Repo.exists?(
               from p in Game.Player,
                 where: p.id == ^player.id and p.game_id == ^game.id and p.is_navigator == true
             )
    end
  end

  describe "join_game/2" do
    test "creates a player", %{game: game} do
      {:ok, player} = Game.join_game(game.id, "Chi")

      assert Repo.exists?(
               from p in Game.Player,
                 where: p.id == ^player.id and p.game_id == ^game.id and p.is_navigator == false
             )
    end

    test "returns an error if game has already enough players", %{game: game} do
      {:ok, _player} = Game.join_game(game.id, "Chi")
      {:ok, _player} = Game.join_game(game.id, "Hen")

      assert {:error, :too_many_players} = Game.join_game(game.id, "Can")
    end

    test "returns an error if the game is unknown" do
      assert {:error, :unknown_game} = Game.join_game("abc", "Chi")
    end
  end

  describe "get_game_by_id/1" do
    test "returns a game", %{game: g} do
      game = Game.get_game_by_id(g.id)

      assert game.id == g.id
      assert game.players == []
    end

    test "returns nil for unsupported id format" do
      assert Game.get_game_by_id("abc") == nil
    end

    test "returns nil for unknown game" do
      assert Game.get_game_by_id("X8kY6JpsQ5Kgf9fu4uBZ4F") == nil
    end
  end

  describe "create_round/1" do
    test "creates a round", %{game: game} do
      {:ok, round} = Game.create_round(game.id)

      assert Repo.exists?(
               from r in Game.Round, where: r.id == ^round.id and r.game_id == ^game.id
             )
    end

    test "creates cards", %{game: game} do
      {:ok, round} = Game.create_round(game.id)
      cards = Game.Card |> from(where: [round_id: ^round.id]) |> Repo.all()

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

  describe "get_last_round/1" do
    test "returns the last round", %{game: game} do
      {:ok, _round1} = Game.create_round(game.id)
      {:ok, _round2} = Game.create_round(game.id)
      {:ok, round3} = Game.create_round(game.id)

      assert Game.get_last_round(game.id).id == round3.id
    end

    test "returns nil for empty list of rounds", %{game: game} do
      assert Game.get_last_round(game.id) == nil
    end

    test "preloads cards", %{game: game} do
      {:ok, _round1} = Game.create_round(game.id)
      last_round = Game.get_last_round(game.id)

      assert length(last_round.cards) > 0
    end
  end
end
