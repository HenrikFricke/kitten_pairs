defmodule KittenMemoryWeb.GameLive do
  use KittenMemoryWeb, :live_view
  alias KittenMemory.Game

  def mount(%{"id" => game_id}, _session, socket) do
    if connected?(socket), do: Game.subscribe(game_id)
    Game.notify(game_id, [:player, :joined])
    game = Game.get_game_by_id(game_id)
    {:ok, assign(socket, :game, game)}
  end

  def handle_info({[:player, :joined], game_id}, socket) do
    game = Game.get_game_by_id(game_id)
    {:noreply, assign(socket, :game, game)}
  end
end
