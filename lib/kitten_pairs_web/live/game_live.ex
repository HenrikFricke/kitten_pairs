defmodule KittenPairsWeb.GameLive do
  use KittenPairsWeb, :live_view
  alias KittenPairs.Game

  defguard current_player?(socket, player_id)
           when socket.assigns.current_player.id === player_id

  def mount(_params, session, socket) when not is_map_key(session, "player_id") do
    {:ok, redirect(socket, to: Routes.page_path(socket, :index))}
  end

  def mount(%{"id" => game_id}, %{"player_id" => player_id}, socket) do
    if connected?(socket), do: Game.subscribe(game_id)
    game = Game.get_game_by_id(game_id)
    current_player = Enum.find(game.players, fn p -> p.id == player_id end)
    Game.notify(game_id, current_player.id, [:player, :joined])

    {:ok, assign(socket, game: game, current_player: current_player)}
  end

  def handle_info({_, player_id, _}, socket)
      when current_player?(socket, player_id) do
    {:noreply, socket}
  end

  def handle_info({[:player, :joined], player_id, _}, socket)
      when not current_player?(socket, player_id) do
    game_id = socket.assigns.game.id
    game = Game.get_game_by_id(game_id)
    {:noreply, assign(socket, :game, game)}
  end
end
