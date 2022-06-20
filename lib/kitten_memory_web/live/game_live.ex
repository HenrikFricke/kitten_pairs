defmodule KittenMemoryWeb.GameLive do
  use KittenMemoryWeb, :live_view
  alias KittenMemory.Game

  def render(assigns) do
    ~H"""
    <%= if length(@game.players) == 1 do %>
      Waiting for your opponent …
    <% else %>
      Ready to rumble
    <% end %>
    """
  end

  def mount(%{"id" => game_id}, _session, socket) do
    game = Game.get_game_by_id(game_id)
    {:ok, assign(socket, :game, game)}
  end
end
