ExUnit.start

Mix.Task.run "ecto.create", ~w(-r RiverPlaceApp.Repo --quiet)
Mix.Task.run "ecto.migrate", ~w(-r RiverPlaceApp.Repo --quiet)
Ecto.Adapters.SQL.begin_test_transaction(RiverPlaceApp.Repo)

