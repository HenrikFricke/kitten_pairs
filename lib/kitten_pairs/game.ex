defmodule KittenPairs.Game do
  import Ecto.Query, warn: false
  alias KittenPairs.Repo
  alias Phoenix.PubSub

  alias KittenPairs.Game.{Player, Game}

  def start_new_game(attrs) do
    {:ok, game} =
      %Game{}
      |> Game.changeset(%{})
      |> Repo.insert()

    {:ok, player} =
      %Player{}
      |> Player.changeset(%{game_id: game.id, name: attrs["name"], is_navigator: true})
      |> Repo.insert()

    %{player_id: player.id, game_id: game.id}
  end

  def join_game(game_id, attrs) do
    %Player{}
    |> Player.changeset(%{game_id: game_id, name: attrs["name"]})
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
