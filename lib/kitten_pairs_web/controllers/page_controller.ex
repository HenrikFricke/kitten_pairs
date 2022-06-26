defmodule KittenPairsWeb.PageController do
  use KittenPairsWeb, :controller

  alias KittenPairs.Game
  alias KittenPairs.Game.{Player}

  def index(conn, _params) do
    changeset = Player.changeset(%Player{})

    render(conn, "form.html",
      changeset: changeset,
      path: Routes.page_path(conn, :start_new_game)
    )
  end

  def start_new_game(conn, %{"player" => player_params}) do
    result = Game.start_new_game(player_params)

    conn
    |> put_session(:player_id, result.player_id)
    |> redirect(to: Routes.live_path(conn, KittenPairsWeb.GameLive, result.game_id))
  end

  def join(conn, %{"id" => game_id}) do
    changeset = Player.changeset(%Player{})

    render(conn, "form.html",
      changeset: changeset,
      path: Routes.page_path(conn, :join_game, game_id)
    )
  end

  def join_game(conn, %{"id" => game_id, "player" => player_params}) do
    {:ok, player} = Game.join_game(game_id, player_params)

    conn
    |> put_session(:player_id, player.id)
    |> redirect(to: Routes.live_path(conn, KittenPairsWeb.GameLive, game_id))
  end
end
