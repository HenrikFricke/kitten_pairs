defmodule KittenPairs.Player do
  use KittenPairs.Schema
  import Ecto.Changeset

  embedded_schema do
    field :name, :string
    field :is_navigator, :boolean
  end

  @doc false
  def changeset(player, attrs \\ %{}) do
    player
    |> cast(attrs, [:name, :is_navigator])
    |> validate_required([:name])
    |> validate_length(:name, max: 8)
  end
end
