defmodule KittenPairs.GameState do
  @moduledoc """
  Model the game state for a classic matching game.
  """

  alias KittenPairs.Player
  alias KittenPairs.Card
  alias __MODULE__

  defstruct id: nil,
            players: [],
            player_turn: nil,
            status: :not_started,
            cards: []

  def new(id, %Player{} = player) do
    %GameState{id: id, players: [%Player{player | is_navigator: true}]}
  end

  def join(%GameState{players: [p1]} = state, %Player{} = player) do
    {:ok, %GameState{state | players: [p1, player]}}
  end

  def join(%GameState{players: [_p1, _p2]} = _state, %Player{} = _player) do
    {:error, :too_many_players}
  end

  def start(%GameState{} = state) do
    player_turn =
      state.players
      |> Enum.shuffle()
      |> Enum.at(0)

    cards =
      Enum.to_list(0..15)
      |> Enum.shuffle()
      |> Enum.map(fn card ->
        %Card{type: "kitten#{rem(card, 8)}"}
      end)

    %GameState{state | status: :playing, player_turn: player_turn, cards: cards}
  end
end
