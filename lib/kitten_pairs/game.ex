defmodule KittenPairs.Game do
  import Ecto.Query, warn: false
  alias KittenPairs.Repo
  alias Phoenix.PubSub

  alias KittenPairs.Game.{Player, Game}

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
    %Player{}
    |> Player.changeset(%{game_id: game_id, name: player_name})
    |> Repo.insert()
  end

  def get_game_by_id(game_id) do
    Repo.get(Game, game_id) |> Repo.preload(:players)
  end

  def subscribe(game_id) do
    PubSub.subscribe(KittenPairs.PubSub, "games:#{game_id}")
  end

  def notify(game_id, player_id, event, payload \\ %{}) do
    PubSub.broadcast(KittenPairs.PubSub, "games:#{game_id}", {event, player_id, payload})
  end
end
