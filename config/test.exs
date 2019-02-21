use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :collaboration, CollaborationWeb.Endpoint,
  http: [port: 4001],
  server: false

# decrease number of encryption rounds for testing
config :pbkdf2_elixir, :rounds, 1

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :collaboration, Collaboration.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "collaboration_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
