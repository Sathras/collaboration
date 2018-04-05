defmodule Collaboration.Repo.Migrations.TopicsAddFeaturedAndMenuString do
  use Ecto.Migration
  def change do
    alter table(:topics) do
      add :slug, :string
      add :featured, :boolean, default: false
    end
    create unique_index(:topics, [:slug])
  end
end
