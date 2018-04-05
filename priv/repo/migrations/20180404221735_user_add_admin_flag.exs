defmodule Collaboration.Repo.Migrations.UserAddAdminFlag do
  use Ecto.Migration

  def change do
    alter table(:users, primary_key: false) do
      add :admin, :boolean, default: false
    end
  end
end
