defmodule KittenPairsWeb.StartpageControllerTest do
  use KittenPairsWeb.ConnCase

  alias KittenPairs.Game

  @create_attrs %{name: "Chi"}

  describe "GET /" do
    test "renders form to start a new game", %{conn: conn} do
      conn = get(conn, Routes.startpage_path(conn, :index))
      assert html_response(conn, 200) =~ "Start new game"
    end
  end

  describe "POST /" do
    test "submission with valid data", %{conn: conn} do
      conn = post(conn, Routes.startpage_path(conn, :create), player: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.live_path(conn, KittenPairsWeb.GameLive, id)
      assert %{"player_id" => _player_id} = get_session(conn)
    end
  end

  describe "GET /join/:id" do
    test "renders form to join a new game", %{conn: conn} do
      conn = get(conn, Routes.startpage_path(conn, :index, "abcdefg"))
      assert html_response(conn, 200) =~ "Join game"
    end
  end

  describe "POST /join/:id" do
    test "submission with valid data", %{conn: conn} do
      {:ok, game, _player} = Game.create_game("Chi")
      conn = post(conn, Routes.startpage_path(conn, :join, game.id), player: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.live_path(conn, KittenPairsWeb.GameLive, id)
      assert %{"player_id" => _player_id} = get_session(conn)
    end

    test "too many players joining the game", %{conn: conn} do
      {:ok, game, _player} = Game.create_game("Chi")
      {:ok, _player} = Game.join_game(game.id, "Can")

      conn = post(conn, Routes.startpage_path(conn, :join, game.id), player: @create_attrs)
      assert redirected_to(conn) == Routes.startpage_path(conn, :index)
      assert get_flash(conn, :error) =~ "Oh no, you can't join the game anymore."
    end

    test "unknown game id", %{conn: conn} do
      conn = post(conn, Routes.startpage_path(conn, :join, "abc"), player: @create_attrs)
      assert redirected_to(conn) == Routes.startpage_path(conn, :index)
      assert get_flash(conn, :error) =~ "Oh no, the game doesn't exist."
    end
  end
end
