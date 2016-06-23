use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :river_place_app, RiverPlaceApp.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
# config :river_place_app, RiverPlaceApp.Repo,
#   adapter: Ecto.Adapters.Postgres,
#   username: "postgres",
#   password: "postgres",
#   database: "river_place_app_test",
#   hostname: "localhost",
#   pool: Ecto.Adapters.SQL.Sandbox

config :river_place_app, RiverPlaceApp.Repo,
  adapter: Ecto.Adapters.MySQL,
  username: "root",
  password: "password",
  database: "river_place_app_test",
  hostname: "localhost"
  pool: Ecto.Adapters.SQL.Sandbox
