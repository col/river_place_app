# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# Configures the endpoint
config :river_place_app, RiverPlaceApp.Endpoint,
  url: [host: "localhost"],
  root: Path.dirname(__DIR__),
  secret_key_base: "FIBarPaQ7yctEMKIVDVJYmDTsXnNq8dPp9kOJfMhH2HazsjAO4qodVLjgUnCPvYK",
  render_errors: [accepts: ~w(html json)],
  pubsub: [name: RiverPlaceApp.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :logger, level: :debug

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"

# Configure phoenix generators
config :phoenix, :generators,
  migration: true,
  binary_id: false

# config :oauth2_server, Oauth2Server.Repo,
#   adapter: Ecto.Adapters.MySQL,
#   username: "root",
#   password: "password",
#   database: "river_place_app_dev",
#   hostname: "localhost"

config :oauth2_server, Oauth2Server.Settings,
  access_token_expiration: 3600,
  refresh_token_expiration: 3600

config :river_place_app, :app_id, "RiverPlaceSkill"
config :river_place_app, :river_place_api, RiverPlaceMock
config :river_place_app, :verify_token, "sample-verify-token"
config :river_place_app, :page_access_token, "sample-page-access-token"

config :porcelain, driver: Porcelain.Driver.Basic

config :alexa_verifier, verifier_client: AlexaVerifier.VerifierClient

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
