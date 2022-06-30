defmodule KittenPairsWeb.AuthPlugTest do
  use KittenPairsWeb.ConnCase
  use Plug.Test

  alias KittenPairsWeb.AuthPlug

  test "request is redirected when session is invalid" do
    conn =
      conn(:get, "/")
      |> Phoenix.ConnTest.init_test_session(%{})
      |> AuthPlug.call(%{})

    assert redirected_to(conn) == Routes.startpage_path(conn, :index)
    assert halt(conn)
  end
end
