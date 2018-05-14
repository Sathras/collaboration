# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :collaboration,
  ecto_repos: [Collaboration.Repo],
  env: Mix.env,
  generators: [binary_id: true]

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

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"

# %% Coherence Configuration %%   Don't remove this line
config :coherence,
  user_schema: Collaboration.Coherence.User,
  repo: Collaboration.Repo,
  module: Collaboration,
  web_module: CollaborationWeb,
  router: CollaborationWeb.Router,
  messages_backend: CollaborationWeb.Coherence.Messages,
  logged_out_url: "/sessions/new",
  user_active_field: true,
  email_from_name: "fuchsberger.us",
  email_from_email: "noreply@fuchsberger.us",
  user_token: true,
  opts: [
    :confirmable,
    :rememberable,
    :registerable,
    :invitable,
    :authenticatable,
    :recoverable,
    :lockable,
    :trackable,
    :unlockable_with_token
  ]

config :coherence, CollaborationWeb.Coherence.Mailer,
  adapter: Swoosh.Adapters.Mailgun,
  api_key: {:system, "APP_MAILGUN_APIKEY"},
  domain: "fuchsberger.us"

# %% End Coherence Configuration %%
