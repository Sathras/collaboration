defmodule Collaboration.Repo.Migrations.AddOrderTopics do
  use Ecto.Migration

  def change do
    alter table(:topics) do
      add :order, :integer
    end
  end
end
