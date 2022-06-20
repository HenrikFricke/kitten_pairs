defmodule KittenMemory.Game do
  import Ecto.Query, warn: false
  alias KittenMemory.Repo

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
end
