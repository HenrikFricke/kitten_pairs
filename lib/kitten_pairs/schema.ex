defmodule KittenPairs.Schema do
  defmacro __using__(_) do
    quote do
      use Ecto.Schema
      @primary_key {:id, Ecto.ShortUUID, autogenerate: true}
      @foreign_key_type Ecto.ShortUUID
      @timestamps_opts [type: :utc_datetime_usec]
    end
  end
end
