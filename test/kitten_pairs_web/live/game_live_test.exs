defmodule KittenPairsWeb.GameLiveTest do
  use KittenPairsWeb.ConnCase
  import Phoenix.LiveViewTest

  alias KittenPairs.Game

  setup %{conn: conn} do
    {:ok, %{game: game, player: player}} = Game.create_game("Chi")
    conn = init_test_session(conn, player_id: player.id)

    %{conn: conn, game: game, player: player}
  end

  describe "game overview" do
    test "waiting for other to join", %{conn: conn, game: game} do
      {:ok, _view, html} = live(conn, "/games/#{game.id}")

      assert html =~ "Share this link with a friend:"
      assert html =~ "http://localhost:4002/join/#{game.id}"
    end

    test "round creation", %{conn: conn, game: game} do
      {:ok, _player} = Game.join_game(game.id, "Hen")
      {:ok, view, _html} = live(conn, "/games/#{game.id}")

      view
      |> element("button#create_round")
      |> render_click()

      assert Game.get_last_round(game.id) != nil
    end

    test "unknown game id", %{conn: conn} do
      path = Routes.startpage_path(conn, :index)

      assert live(conn, "/games/abc") == {:error, {:redirect, %{flash: %{}, to: path}}}
    end
  end

  describe "round" do
    setup %{conn: conn, game: game, player: player} do
      {:ok, _player} = Game.join_game(game.id, "Hen")
      {:ok, _round} = Game.create_round(game.id, player.id)

      %{conn: conn, game: game}
    end

    test "initial render", %{conn: conn, game: game} do
      {:ok, _view, html} = live(conn, "/games/#{game.id}")

      assert html =~ "kitten0"
    end
  end
end
