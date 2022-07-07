defmodule KittenPairsWeb.StartpageController do
  use KittenPairsWeb, :controller

  alias KittenPairs.Game
  alias KittenPairs.Game.{Player}

  def index(conn, params) do
    changeset = Player.changeset(%Player{})

    render(conn, "form.html",
      changeset: changeset,
      path: form_redirect_path(conn, params),
      button_label: button_label(params)
    )
  end

  def create(conn, %{"player" => p}) do
    case Game.create_game(p["name"]) do
      {:ok, %{game: game, player: player}} ->
        conn
        |> put_session(:player_id, player.id)
        |> redirect(to: Routes.live_path(conn, KittenPairsWeb.GameLive, game.id))

      {:error, :player, _changeset, _changes_so_far} ->
        conn
        |> put_flash(:error, "Your name can have at most 8 characters 😇")
        |> redirect(to: Routes.startpage_path(conn, :index))

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

      {:error, :unknown_game} ->
        conn
        |> put_flash(
          :error,
          "Oh no, the game doesn't exist. Feel free to create a new game and share it with a friend."
        )
        |> redirect(to: Routes.startpage_path(conn, :index))

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

  defp button_label(%{"id" => _game_id}), do: "Join game"
  defp button_label(_params), do: "Start new game"

  defp form_redirect_path(conn, %{"id" => game_id}),
    do: Routes.startpage_path(conn, :join, game_id)

  defp form_redirect_path(conn, _params), do: Routes.startpage_path(conn, :create)
end
