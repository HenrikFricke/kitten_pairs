defmodule KittenPairs.Repo.Migrations.MakeTimestampsUsec do
  use Ecto.Migration

  def change do
    # For each of the listed tables, change the type of :inserted_at and :updated_at to microsecond precision
    ~w/games players rounds/
    |> Enum.map(&String.to_atom/1)
    |> Enum.each(fn table_name ->
      alter table(table_name) do
        modify :inserted_at, :utc_datetime_usec
        modify :updated_at, :utc_datetime_usec
      end
    end)
  end
end
