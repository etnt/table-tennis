import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :table_tennis, TableTennis.Repo,
  username: "postgres",
  password: "mortuta42",
  hostname: "localhost",
  database: "table_tennis_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :table_tennis, TableTennisWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "kebgRc/pt45kl6VNU6/R085Y8Ncx4XBqPBzft9y+b3Bl2HSj4TuPtmm1o6J5JFcG",
  server: false

# In test we don't send emails.
config :table_tennis, TableTennis.Mailer, adapter: Swoosh.Adapters.Test

# Disable swoosh api client as it is only required for production adapters.
config :swoosh, :api_client, false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
