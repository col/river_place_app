use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :river_place_app, RiverPlaceApp.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :debug

config :river_place_app, RiverPlaceApp.Repo,
  adapter: Ecto.Adapters.MySQL,
  username: "root",
  password: "",
  database: "river_place_app_test",
  hostname: "localhost"
  # pool: 10
  # pool: Ecto.Adapters.SQL.Sandbox

config :oauth2_server, Oauth2Server.Repo,
  adapter: Ecto.Adapters.MySQL,
  username: "root",
  password: "",
  database: "river_place_app_test",
  hostname: "localhost"
  # pool: 10
  # pool: Ecto.Adapters.SQL.Sandbox

config :river_place_app, :river_place_api, RiverPlaceMock

config :alexa_verifier, verifier_service_url: "http://localhost:5000"
