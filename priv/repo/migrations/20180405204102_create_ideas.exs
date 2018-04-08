defmodule Collaboration.Repo.Migrations.CreateIdeas do
  use Ecto.Migration

  def change do
    create table(:ideas) do
      add :title, :string
      add :desc, :string
      add :topic_id, references(:topics)
      add :user_id, references(:users, type: :binary_id)
      timestamps()
    end
  end
end
