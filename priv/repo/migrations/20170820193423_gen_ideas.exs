defmodule Collaboration.Repo.Migrations.GenIdeas do
  use Ecto.Migration

  def change do
    create table(:ideas) do
      add :title, :string
      add :description, :string
      add :topic_id, references(:topics, on_delete: :nothing)
      add :user_id, references(:users, on_delete: :nothing)
      timestamps()
    end

    create index(:ideas, [:topic_id])
    create index(:ideas, [:user_id])
  end
end
