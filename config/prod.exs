use Mix.Config

# For production, we configure the host to read the PORT
# from the system environment. Therefore, you will need
# to set PORT=80 before running your server.
#
# You should also configure the url host to something
# meaningful, we use this information when generating URLs.
#
# Finally, we also include the path to a manifest
# containing the digested version of static files. This
# manifest is generated by the mix phoenix.digest task
# which you typically run after static files are built.

config :collaboration, CollaborationWeb.Endpoint,
  http: [port: 4003],
  url: [scheme: "https", host: "collaboration.fuchsberger.us", port: 443],
  cache_static_manifest: "priv/static/cache_manifest.json",
  server: true,
  code_reloader: false,
  version: Application.spec(:collaboration, :vsn)

config :collaboration, CollaborationWeb.Endpoint,
  secret_key_base: System.get_env("SECRET_KEY_BASE")

config :collaboration, Collaboration.Repo,
  hostname: System.get_env("DB_HOSTNAME"),
  username: System.get_env("DB_USERNAME"),
  password: System.get_env("DB_PASSWORD"),
  database: "collaboration_prod",
  pool_size: 5

config :collaboration,
  ga_code: "UA-119138942-1",                      # Google Analytics Code
  password: System.get_env("PASSWORD_DEFAULT")    # admin user password

# This line appears further down. Do not forget to uncomment it!
config :phoenix, :serve_endpoints, true
