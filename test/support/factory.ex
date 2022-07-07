defmodule KittenPairs.Factory do
  use ExMachina.Ecto, repo: KittenPairs.Repo

  def game_factory do
    %KittenPairs.Game.Game{}
  end

  def player_factory do
    %KittenPairs.Game.Player{
      name: "Hen"
    }
  end

  def round_factory do
    %KittenPairs.Game.Round{}
  end

  def card_factory do
    %KittenPairs.Game.Card{}
  end

  def turn_factory do
    %KittenPairs.Game.Turn{}
  end
end
