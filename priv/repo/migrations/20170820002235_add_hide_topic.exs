defmodule Collaboration.Repo.Migrations.AddHideTopic do
  use Ecto.Migration

  def change do
    alter table(:topics) do
      add :hidden, :boolean
    end

    create unique_index(:topics, [:title])
    create unique_index(:topics, [:menutitle])
  end
end
