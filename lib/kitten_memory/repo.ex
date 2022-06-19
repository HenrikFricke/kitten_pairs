defmodule KittenMemory.Repo do
  use Ecto.Repo,
    otp_app: :kitten_memory,
    adapter: Ecto.Adapters.Postgres
end
