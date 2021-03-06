import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :kitten_pairs, KittenPairs.Repo,
  url: System.get_env("DATABASE_URL", "ecto://postgres:postgres@localhost/kitten_pairs_test"),
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10,
  migration_primary_key: [name: :id, type: :binary_id],
  show_sensitive_data_on_connection_error: true

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :kitten_pairs, KittenPairsWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "LxBPTUOKSJEX7CCJQ0g5a3zYfKax3IIOAENeEQaUGajmv/z9wQLjD3qq8+QEq5nE",
  server: false

# In test we don't send emails.
config :kitten_pairs, KittenPairs.Mailer, adapter: Swoosh.Adapters.Test

# Print only warnings and errors during test
config :logger, level: :warn

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
