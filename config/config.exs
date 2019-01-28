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
  # own configuration
  minTime: 10 * 60,             # minimal experiment time [sec]
  passcode: "orange",           # passcode required for experiment (lower case)
  password: "Z%mK9Gh4M9Bbn#Y5"  # default password for participant users

# Configures the endpoint
config :collaboration, CollaborationWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base:
    "Rm2mIp4+FjNMBwPx9+pnMZ8AAEE4/diJQZ0NSBqZlE3BAo2+0rV7cDNmlrEbt9KO",
  render_errors: [view: CollaborationWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Collaboration.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Drab
config :drab, CollaborationWeb.Endpoint,
  otp_app: :collaboration

# Configures default Drab file extension
config :phoenix, :template_engines,
  drab: Drab.Live.Engine

# Configures Drab for webpack
config :drab, CollaborationWeb.Endpoint,
  js_socket_constructor: "window.__socket"

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:user_id]

# %% Coherence Configuration %%   Don't remove this line
config :coherence,
  user_schema: Collaboration.Coherence.User,
  repo: Collaboration.Repo,
  module: Collaboration,
  web_module: CollaborationWeb,
  router: CollaborationWeb.Router,
  messages_backend: CollaborationWeb.Coherence.Messages,
  logged_out_url: "/sessions/new",
  email_from_name: "fuchsberger.us",
  email_from_email: "noreply@fuchsberger.us",
  user_token: true,
  opts: [
    :rememberable,
    :invitable,
    :authenticatable,
    :recoverable,
    :trackable
  ]

config :coherence, CollaborationWeb.Coherence.Mailer,
  adapter: Swoosh.Adapters.Mailgun,
  api_key: {:system, "APP_MAILGUN_APIKEY"},
  domain: "fuchsberger.us"

# %% End Coherence Configuration %%

config :phoenix, :json_library, Jason
config :phoenix, :template_engines, drab: Drab.Live.Engine

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
