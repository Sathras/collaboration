# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :collaboration,
  ecto_repos: [Collaboration.Repo],
  env: Mix.env

# Configures the endpoint
config :collaboration, CollaborationWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base:
    "Rm2mIp4+FjNMBwPx9+pnMZ8AAEE4/diJQZ0NSBqZlE3BAo2+0rV7cDNmlrEbt9KO",
  render_errors: [view: CollaborationWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Collaboration.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:user_id]

config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"

# Import Application Settings
import_config "app.exs"
