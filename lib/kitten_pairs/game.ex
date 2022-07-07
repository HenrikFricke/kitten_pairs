defmodule KittenPairs.Game do
  import Ecto.Query, warn: false
  alias KittenPairs.Repo
  alias Phoenix.PubSub

  alias KittenPairs.Game.{Player, Game, Round, Card, Turn}

  def create_game(player_name) do
    Ecto.Multi.new()
    |> Ecto.Multi.insert(:game, %Game{})
    |> Ecto.Multi.insert(:player, fn %{game: game} ->
      %Player{}
      |> Player.changeset(%{game_id: game.id, name: player_name, is_navigator: true})
    end)
    |> Repo.transaction()
  end

  def join_game(game_id, player_name) do
    case get_game_by_id(game_id) do
      nil ->
        {:error, :unknown_game}

      game ->
        if length(game.players) < 2 do
          %Player{}
          |> Player.changeset(%{game_id: game_id, name: player_name})
          |> Repo.insert()
        else
          {:error, :too_many_players}
        end
    end
  end

  def get_game_by_id(game_id) do
    Game
    |> Repo.get(game_id)
    |> Repo.preload(:players)
  rescue
    Ecto.Query.CastError -> nil
  end

  def create_round(game_id, player_id) do
    {:ok, round} =
      %Round{}
      |> Round.changeset(%{game_id: game_id})
      |> Repo.insert()

    Enum.to_list(0..15)
    |> Enum.shuffle()
    |> Enum.each(fn card ->
      Repo.insert(Card.changeset(%Card{}, %{type: "kitten#{rem(card, 8)}", round_id: round.id}))
    end)

    %Turn{}
    |> Turn.changeset(%{round_id: round.id, player_id: player_id})
    |> Repo.insert()

    {:ok, round}
  end

  def get_last_round(game_id) do
    Round
    |> from(where: [game_id: ^game_id])
    |> last(:inserted_at)
    |> Repo.one()
    |> Repo.preload(
      cards:
        from(
          c in Card,
          order_by: [desc: c.inserted_at]
        )
    )
  end

  def get_last_turn(round_id) do
    Turn
    |> from(where: [round_id: ^round_id])
    |> last(:inserted_at)
    |> Repo.one()
    |> Repo.preload(:cards)
  end

  def pick_card(turn_id, card_id) do
    card = Repo.get(Card, card_id) |> Repo.preload(:turns)
    turn = Repo.get(Turn, turn_id)

    card
    |> Card.changeset(%{is_visible: true})
    |> Ecto.Changeset.put_assoc(:turns, [turn | card.turns])
    |> Repo.update()
  end

  def complete_turn(game_id, round_id, turn_id) do
    game = Repo.get(Game, game_id) |> Repo.preload(:players)
    round = Repo.get(Round, round_id) |> Repo.preload(:cards)
    turn = Repo.get(Turn, turn_id) |> Repo.preload(:cards)
    first_card = Enum.at(turn.cards, 0)
    second_card = Enum.at(turn.cards, 1)
    is_match = first_card.type == second_card.type
    num_of_open_pairs = length(Enum.filter(round.cards, fn c -> !c.is_visible end)) / 2

    next_player_id =
      if is_match,
        do: turn.player_id,
        else: Enum.find(game.players, fn p -> p.id != turn.player_id end).id

    first_card
    |> Card.changeset(%{is_visible: is_match})
    |> Repo.update()

    second_card
    |> Card.changeset(%{is_visible: is_match})
    |> Repo.update()

    if num_of_open_pairs >= 1 do
      %Turn{}
      |> Turn.changeset(%{round_id: round_id, player_id: next_player_id})
      |> Repo.insert()
    end
  end

  def subscribe(game_id) do
    PubSub.subscribe(KittenPairs.PubSub, "games:#{game_id}")
  end

  def notify(game_id, player_id, event, payload \\ %{}) do
    PubSub.broadcast(KittenPairs.PubSub, "games:#{game_id}", {event, player_id, payload})
  end
end
