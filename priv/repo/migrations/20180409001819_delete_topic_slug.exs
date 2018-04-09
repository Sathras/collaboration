defmodule Collaboration.Repo.Migrations.DeleteTopicSlug do
  use Ecto.Migration

  def change do
    alter table(:topics) do
      remove :slug
    end
  end
end
