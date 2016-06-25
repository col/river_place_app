defmodule RiverPlaceApp.Repo.Migrations.AddRiverPlaceCredentials do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :rp_username, :string
      add :rp_password, :string
    end
  end
end
