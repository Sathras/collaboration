# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :collaboration,
  ecto_repos: [Collaboration.Repo]

# Configures the endpoint
config :collaboration, Collaboration.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "HX8FIfh58Rng5qSkP7fJrLPx4J1sCi7FxpDwgquwut34QLBZFKn5k54pOF2MgsEy",
  render_errors: [view: Collaboration.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Collaboration.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
