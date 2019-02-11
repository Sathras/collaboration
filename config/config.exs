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
  bi_low_minTime: 45,             # BI(L) min time (40 sec -> 15 per experiment)
  bi_low_maxTime: 65,             # BI(L) max time (60 sec -> 10 per experiment)
  bi_high_minTime: 4 * 60,        # BI(H) min time (4 min -> 2 per experiment)
  bi_high_maxTime: 5 * 60,        # BI(H) max time (5 min -> 2 per experiment)
  ga_dev_code: "UA-119119225-1",  # Google Analytics Dev Code
  ga_prod_code: "UA-119138942-1", # Google Analytics Production Code
  minTime: 10 * 60,               # minimal experiment time [sec]
  passcode: System.get_env("PASSCODE"), # passcode required for experiment
  password: System.get_env("PASSWORD_DEFAULT"),  # experiment user password
  survey_codes: %{                # needed for survey upon finishing experiment
    1 => "condition 1 code",
    2 => "condition 2 code",
    3 => "condition 3 code",
    4 => "condition 4 code",
    5 => "condition 5 code",
    6 => "condition 6 code",
    7 => "condition 7 code",
    8 => "condition 8 code"
  }

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
  email_from_name: "fuchsberger.us",
  email_from_email: "noreply@fuchsberger.us",
  user_token: true,
  opts: [
    :rememberable,
    :authenticatable,
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
