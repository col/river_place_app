defmodule RiverPlaceApp.Repo.Migrations.AddRedirectUrlToClients do
  use Ecto.Migration

  def change do
    alter table(:oauth_clients) do
      add :redirect_url, :string
    end
  end
end
