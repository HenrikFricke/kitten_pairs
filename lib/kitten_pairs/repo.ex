defmodule KittenPairs.Repo do
  use Ecto.Repo,
    otp_app: :kitten_pairs,
    adapter: Ecto.Adapters.Postgres
end
