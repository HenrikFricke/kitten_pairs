defmodule KittenMemoryWeb.PageController do
  use KittenMemoryWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
