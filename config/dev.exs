use Mix.Config

# For development, we disable any cache and enable
# debugging and code reloading.
#
# The watchers configuration can be used to run external
# watchers to your application. For example, we use it
# with brunch.io to recompile .js and .css sources.
config :river_place_app, RiverPlaceApp.Endpoint,
  http: [port: 4000],
  debug_errors: true,
  code_reloader: true,
  check_origin: false,
  watchers: [node: ["node_modules/brunch/bin/brunch", "watch", "--stdin"]]

# Watch static and templates for browser reloading.
config :river_place_app, RiverPlaceApp.Endpoint,
  live_reload: [
    patterns: [
      ~r{priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$},
      ~r{priv/gettext/.*(po)$},
      ~r{web/views/.*(ex)$},
      ~r{web/templates/.*(eex)$}
    ]
  ]

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"

# Set a higher stacktrace during development.
# Do not configure such in production as keeping
# and calculating stacktraces is usually expensive.
config :phoenix, :stacktrace_depth, 20

config :river_place_app, RiverPlaceApp.Repo,
  adapter: Ecto.Adapters.MySQL,
  username: "root",
  password: "",
  database: "river_place_app_dev",
  hostname: "localhost",
  pool_size: 10

config :oauth2_server, Oauth2Server.Repo,
    adapter: Ecto.Adapters.MySQL,
    username: "root",
    password: "",
    database: "river_place_app_dev",
    hostname: "localhost",
    pool_size: 10

config :river_place_app, :river_place_api, RiverPlace

config :alexa_verifier, verifier_service_url: "http://localhost:5000"
