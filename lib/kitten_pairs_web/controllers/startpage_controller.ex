defmodule KittenPairsWeb.StartpageController do
  use KittenPairsWeb, :controller

  alias KittenPairs.Game
  alias KittenPairs.Game.{Player}

  def index(conn, %{"id" => game_id}) do
    changeset = Player.changeset(%Player{})

    render(conn, "form.html",
      changeset: changeset,
      path: Routes.startpage_path(conn, :join, game_id),
      button_label: "Join game"
    )
  end

  def index(conn, _params) do
    changeset = Player.changeset(%Player{})

    render(conn, "form.html",
      changeset: changeset,
      path: Routes.startpage_path(conn, :create),
      button_label: "Start new game"
    )
  end

  def create(conn, %{"player" => player}) do
    case Game.create_game(player["name"]) do
      {:ok, game, player} ->
        conn
        |> put_session(:player_id, player.id)
        |> redirect(to: Routes.live_path(conn, KittenPairsWeb.GameLive, game.id))

      _ ->
        conn
        |> put_flash(:error, "Hm, something went wrong. Pls try again later.")
        |> redirect(to: Routes.startpage_path(conn, :index))
    end
  end

  def join(conn, %{"id" => game_id, "player" => player}) do
    case Game.join_game(game_id, player["name"]) do
      {:ok, player} ->
        conn
        |> put_session(:player_id, player.id)
        |> redirect(to: Routes.live_path(conn, KittenPairsWeb.GameLive, game_id))

      {:error, :too_many_players} ->
        conn
        |> put_flash(
          :error,
          "Oh no, you can't join the game anymore. Feel free to create a new game and share it with a friend."
        )
        |> redirect(to: Routes.startpage_path(conn, :index))

      _ ->
        conn
        |> put_flash(:error, "Hm, something went wrong. Pls try again later.")
        |> redirect(to: Routes.startpage_path(conn, :index, game_id))
    end
  end
end
