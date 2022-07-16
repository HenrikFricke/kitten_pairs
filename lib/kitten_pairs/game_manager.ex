defmodule KittenPairs.GameManager do
  import Ecto.Query, warn: false
  alias KittenPairs.Repo
  alias Phoenix.PubSub

  alias KittenPairs.Game.{Player, Game, Round, Card, Turn, RoundScore, TurnCard}

  def create_game(player_name) do
    Ecto.Multi.new()
    |> Ecto.Multi.insert(:game, %Game{})
    |> Ecto.Multi.insert(:player, fn %{game: game} ->
      Player.changeset(%Player{}, %{game_id: game.id, name: player_name, is_navigator: true})
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

  def get_game_by_id(id) do
    Game
    |> Repo.get(id)
    |> Repo.preload(:players)
  rescue
    Ecto.Query.CastError -> nil
  end

  def create_round(game_id, player_id) do
    Ecto.Multi.new()
    |> Ecto.Multi.all(:players, from(p in Player, where: p.game_id == ^game_id))
    |> Ecto.Multi.insert(:round, Round.changeset(%Round{}, %{game_id: game_id}))
    |> Ecto.Multi.insert(:first_turn, fn %{round: round} ->
      Turn.changeset(%Turn{}, %{round_id: round.id, player_id: player_id})
    end)
    |> Ecto.Multi.run(:round_scores, fn repo, %{players: players, round: round} ->
      players
      |> Enum.each(fn player ->
        repo.insert(
          RoundScore.changeset(%RoundScore{}, %{round_id: round.id, player_id: player.id})
        )
      end)

      {:ok, nil}
    end)
    |> Ecto.Multi.run(:cards, fn repo, %{round: round} ->
      Enum.to_list(0..15)
      |> Enum.shuffle()
      |> Enum.map(fn card ->
        repo.insert(Card.changeset(%Card{}, %{type: "kitten#{rem(card, 8)}", round_id: round.id}))
      end)

      {:ok, nil}
    end)
    |> Repo.transaction()
  end

  def get_last_round(game_id) do
    Round
    |> from(where: [game_id: ^game_id])
    |> last(:inserted_at)
    |> Repo.one()
    |> Repo.preload([:round_scores, cards: from(c in Card, order_by: [desc: c.inserted_at])])
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

  def complete_turn(turn_id) do
    turn =
      Turn
      |> Repo.get(turn_id)
      |> Repo.preload([:cards, round: [:cards, game: [:players]]])

    first_card = Enum.at(turn.cards, 0)
    second_card = Enum.at(turn.cards, 1)
    is_match = first_card.type == second_card.type
    increase_round_score = if is_match, do: 1, else: 0
    is_round_completed = length(Enum.filter(turn.round.cards, fn c -> not c.is_visible end)) == 0

    next_player_id =
      if is_match,
        do: turn.player_id,
        else: Enum.find(turn.round.game.players, fn p -> p.id != turn.player_id end).id

    Ecto.Multi.new()
    |> Ecto.Multi.update_all(
      :cards,
      from(c in Card,
        join: tc in TurnCard,
        on: tc.card_id == c.id,
        update: [set: [is_visible: ^is_match]],
        where: tc.turn_id == ^turn.id
      ),
      []
    )
    |> Ecto.Multi.update_all(
      :round_score,
      from(r in RoundScore,
        update: [inc: [score: ^increase_round_score]],
        where: r.round_id == ^turn.round.id and r.player_id == ^turn.player_id
      ),
      []
    )
    |> Ecto.Multi.run(:new_turn, fn repo, _ ->
      unless is_round_completed do
        repo.insert(
          Turn.changeset(%Turn{}, %{round_id: turn.round.id, player_id: next_player_id})
        )
      else
        {:ok, %{}}
      end
    end)
    |> Repo.transaction()
  end

  def subscribe(game_id) do
    PubSub.subscribe(KittenPairs.PubSub, "games:#{game_id}")
  end

  def notify(game_id, player_id, event, payload \\ %{}) do
    PubSub.broadcast(KittenPairs.PubSub, "games:#{game_id}", {event, player_id, payload})
  end
end
