defmodule Collaboration.Repo.Migrations.CreateLikes do
  use Ecto.Migration

  def change do
    create table(:likes) do
      add :user_id, references(:users, type: :binary_id)
      add :comment_id, references(:comments)
    end

    create unique_index(:likes, [:user_id, :comment_id])
  end
end
