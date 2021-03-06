defmodule KittenPairsWeb.GameLive do
  use KittenPairsWeb, :live_view
  alias KittenPairs.GameManager

  defguard current_player?(socket, player_id)
           when socket.assigns.current_player.id === player_id

  def mount(%{"id" => game_id}, %{"player_id" => player_id}, socket) do
    if connected?(socket), do: GameManager.subscribe(game_id)

    case GameManager.get_game_by_id(game_id) do
      nil ->
        {:ok, redirect(socket, to: Routes.startpage_path(socket, :index))}

      game ->
        last_round = GameManager.get_last_round(game.id)
        last_turn = if last_round, do: GameManager.get_last_turn(last_round.id), else: nil
        current_player = Enum.find(game.players, fn p -> p.id == player_id end)
        join_link = Routes.startpage_url(socket, :index, game.id)

        GameManager.notify(game_id, current_player.id, [:player, :joined])

        {:ok,
         assign(socket,
           game: game,
           current_player: current_player,
           join_link: join_link,
           last_round: last_round,
           last_turn: last_turn
         )}
    end
  end

  def handle_event("create_round", _value, socket) do
    game_id = socket.assigns.game.id
    current_player_id = socket.assigns.current_player.id

    GameManager.create_round(game_id)
    GameManager.notify(game_id, current_player_id, [:round, :created])

    {:noreply, socket}
  end

  def handle_event("pick_card", %{"id" => card_id}, socket) do
    game_id = socket.assigns.game.id
    last_turn = socket.assigns.last_turn
    current_player_id = socket.assigns.current_player.id

    GameManager.pick_card(last_turn.id, card_id)
    GameManager.notify(game_id, current_player_id, [:card, :picked])

    if length(last_turn.cards) == 1 do
      Task.start(fn ->
        Process.sleep(1000)
        GameManager.complete_turn(last_turn.id)
        GameManager.notify(game_id, current_player_id, [:turn, :completed])
      end)
    end

    {:noreply, socket}
  end

  def handle_info({[:player, :joined], player_id, _}, socket)
      when not current_player?(socket, player_id) do
    game_id = socket.assigns.game.id
    game = GameManager.get_game_by_id(game_id)

    {:noreply, assign(socket, :game, game)}
  end

  def handle_info({[:round, :created], _player_id, _}, socket) do
    game_id = socket.assigns.game.id
    last_round = GameManager.get_last_round(game_id)
    last_turn = GameManager.get_last_turn(last_round.id)

    {:noreply, assign(socket, last_round: last_round, last_turn: last_turn)}
  end

  def handle_info({[:card, :picked], _player_id, _}, socket) do
    game_id = socket.assigns.game.id
    last_round = GameManager.get_last_round(game_id)
    last_turn = GameManager.get_last_turn(last_round.id)

    {:noreply, assign(socket, last_round: last_round, last_turn: last_turn)}
  end

  def handle_info({[:turn, :completed], _player_id, _}, socket) do
    game_id = socket.assigns.game.id
    last_round = GameManager.get_last_round(game_id)
    last_turn = GameManager.get_last_turn(last_round.id)

    {:noreply, assign(socket, last_round: last_round, last_turn: last_turn)}
  end

  def handle_info({_, player_id, _}, socket)
      when current_player?(socket, player_id) do
    {:noreply, socket}
  end
end
