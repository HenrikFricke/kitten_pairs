defmodule KittenPairsWeb.AuthPlug do
  import Plug.Conn
  import Phoenix.Controller
  import KittenPairsWeb.Router.Helpers

  def init(_params) do
  end

  def call(conn, _params) do
    case Plug.Conn.get_session(conn, :player_id) do
      nil ->
        conn
        |> redirect(to: startpage_path(conn, :index))
        |> halt()

      _ ->
        conn
    end
  end
end
