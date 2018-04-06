defmodule Collaboration.Repo.Migrations.CreateIdeas do
  use Ecto.Migration

  def change do
    create table(:ideas, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :title, :string
      add :desc, :string
      add :topic_id, references(:topics, type: :binary_id)
      add :user_id, references(:users, type: :binary_id)
      timestamps()
    end
  end
end
