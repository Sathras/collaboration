defmodule Collaboration.Repo.Migrations.FauxusersClosedtopics do
  use Ecto.Migration

  def change do
    alter table(:topics) do
      add :closed, :boolean
    end
    alter table(:users) do
      add :faux, :boolean
    end
  end
end
