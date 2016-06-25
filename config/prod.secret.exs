use Mix.Config

# In this file, we keep production configuration that
# you likely want to automate and keep it away from
# your version control system.
config :river_place_app, RiverPlaceApp.Endpoint,
  secret_key_base: System.get_env("SECRET_KEY_BASE")

config :river_place_app, RiverPlaceApp.Repo,
  adapter: Ecto.Adapters.MySQL,
  url: System.get_env("DATABASE_URL"),
  pool_size: 20

config :oauth2_server, Oauth2Server.Repo,
  adapter: Ecto.Adapters.MySQL,
  url: System.get_env("DATABASE_URL"),
  pool_size: 20

config :river_place_app, :app_id, [System.get_env("RIVER_PLACE_SKILL_APP_ID"), "RiverPlaceSkill"]
