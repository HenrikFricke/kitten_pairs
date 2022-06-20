defmodule KittenMemory.Game do
  import Ecto.Query, warn: false
  alias KittenMemory.Repo
  alias Phoenix.PubSub

  alias KittenMemory.Game.{Player, Game}

  def start_new_game(attrs) do
    {:ok, game} =
      %Game{}
      |> Game.changeset(%{})
      |> Repo.insert()

    {:ok, player} =
      %Player{}
      |> Player.changeset(%{game_id: game.id, name: attrs["name"]})
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
    PubSub.subscribe(KittenMemory.PubSub, "games:#{game_id}")
  end

  def notify(game_id, event) do
    PubSub.broadcast(KittenMemory.PubSub, "games:#{game_id}", {event, game_id})
  end
end
