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

      assert %{"player_id" => player_id} = get_session(conn)
      assert %{:players => players} = Game.get_game_by_id(id)
      assert Enum.any?(players, fn p -> p.id == player_id end)
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

      assert %{"player_id" => player_id} = get_session(conn)
      assert %{:players => players} = Game.get_game_by_id(id)
      assert Enum.any?(players, fn p -> p.id == player_id end)
    end
  end
end
