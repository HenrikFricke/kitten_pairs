defmodule KittenPairs.GameTest do
  use KittenPairs.DataCase

  alias KittenPairs.Game

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
    test "creates a player" do
      {:ok, game} = Repo.insert(%Game.Game{})
      {:ok, player} = Game.join_game(game.id, "Chi")

      assert Repo.exists?(
               from p in Game.Player,
                 where: p.id == ^player.id and p.game_id == ^game.id and p.is_navigator == false
             )
    end
  end

  describe "get_game_by_id/1" do
    test "returns a game" do
      {:ok, g} = Repo.insert(%Game.Game{})
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
end
