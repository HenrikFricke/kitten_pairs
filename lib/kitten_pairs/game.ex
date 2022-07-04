defmodule KittenPairs.Game do
  import Ecto.Query, warn: false
  alias KittenPairs.Repo
  alias Phoenix.PubSub

  alias KittenPairs.Game.{Player, Game, Round, Card}

  def create_game(player_name) do
    {:ok, game} =
      %Game{}
      |> Game.changeset(%{})
      |> Repo.insert()

    {:ok, player} =
      %Player{}
      |> Player.changeset(%{game_id: game.id, name: player_name, is_navigator: true})
      |> Repo.insert()

    {:ok, game, player}
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

  def create_round(game_id) do
    {:ok, round} =
      %Round{}
      |> Round.changeset(%{game_id: game_id})
      |> Repo.insert()

    Enum.to_list(0..15)
    |> Enum.shuffle()
    |> Enum.each(fn card ->
      Repo.insert(Card.changeset(%Card{}, %{type: "kitten#{rem(card, 8)}", round_id: round.id}))
    end)

    {:ok, round}
  end

  def get_last_round(game_id) do
    Round
    |> from(where: [game_id: ^game_id])
    |> last(:inserted_at)
    |> Repo.one()
    |> Repo.preload(:cards)
  end

  def subscribe(game_id) do
    PubSub.subscribe(KittenPairs.PubSub, "games:#{game_id}")
  end

  def notify(game_id, player_id, event, payload \\ %{}) do
    PubSub.broadcast(KittenPairs.PubSub, "games:#{game_id}", {event, player_id, payload})
  end
end
