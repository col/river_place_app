RiverPlaceSkill.start_link([app_id: "test-app-id"])
ExUnit.start
Pavlov.start

Mix.Task.run "ecto.create", ~w(-r RiverPlaceApp.Repo --quiet)
Mix.Task.run "ecto.migrate", ~w(-r RiverPlaceApp.Repo --quiet)
# Ecto.Adapters.SQL.begin_test_transaction(RiverPlaceApp.Repo)
# Ecto.Adapters.SQL.begin_test_transaction(Oauth2Server.Repo)

Oauth2Server.Repo.delete_all(Oauth2Server.OauthAccessToken)
Oauth2Server.Repo.delete_all(Oauth2Server.OauthRefreshToken)
Oauth2Server.Repo.delete_all(Oauth2Server.OauthClient)
RiverPlaceApp.Repo.delete_all(RiverPlaceApp.User)

RiverPlace.start(:normal, [])
