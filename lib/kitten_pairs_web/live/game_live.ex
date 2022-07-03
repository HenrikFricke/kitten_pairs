defmodule KittenPairsWeb.GameLive do
  use KittenPairsWeb, :live_view
  alias KittenPairs.Game

  defguard current_player?(socket, player_id)
           when socket.assigns.current_player.id === player_id

  def mount(%{"id" => game_id}, %{"player_id" => player_id}, socket) do
    if connected?(socket), do: Game.subscribe(game_id)

    case Game.get_game_by_id(game_id) do
      nil ->
        {:ok, redirect(socket, to: Routes.startpage_path(socket, :index))}

      game ->
        last_round = Game.get_last_round(game.id)
        current_player = Enum.find(game.players, fn p -> p.id == player_id end)
        join_link = Routes.startpage_url(socket, :index, game.id)
        Game.notify(game_id, current_player.id, [:player, :joined])

        {:ok,
         assign(socket,
           game: game,
           current_player: current_player,
           join_link: join_link,
           last_round: last_round
         )}
    end
  end

  def handle_event("create_round", _value, socket) do
    game_id = socket.assigns.game.id
    current_player_id = socket.assigns.current_player.id

    case Game.create_round(game_id) do
      {:ok, round} ->
        Game.notify(game_id, current_player_id, [:round, :created])

        {:noreply, assign(socket, :last_round, round)}
    end
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

  def handle_info({[:round, :created], player_id, _}, socket)
      when not current_player?(socket, player_id) do
    game_id = socket.assigns.game.id
    last_round = Game.get_last_round(game_id)

    {:noreply, assign(socket, :last_round, last_round)}
  end
end
