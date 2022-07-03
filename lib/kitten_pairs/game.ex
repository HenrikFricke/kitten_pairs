defmodule KittenPairs.Game do
  import Ecto.Query, warn: false
  alias KittenPairs.Repo
  alias Phoenix.PubSub

  alias KittenPairs.Game.{Player, Game, Round}

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
    case Repo.get(Game, game_id) do
      nil -> nil
      game -> Repo.preload(game, :players)
    end
  rescue
    Ecto.Query.CastError -> nil
  end

  def create_round(game_id) do
    %Round{}
    |> Round.changeset(%{game_id: game_id})
    |> Repo.insert()
  end

  def get_last_round(game_id) do
    Round
    |> from(where: [game_id: ^game_id])
    |> last(:inserted_at)
    |> Repo.one()
  end

  def subscribe(game_id) do
    PubSub.subscribe(KittenPairs.PubSub, "games:#{game_id}")
  end

  def notify(game_id, player_id, event, payload \\ %{}) do
    PubSub.broadcast(KittenPairs.PubSub, "games:#{game_id}", {event, player_id, payload})
  end
end
