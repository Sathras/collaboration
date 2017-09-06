defmodule Collaboration.Repo.Migrations.CreateReaction do
  use Ecto.Migration

  def change do

    create table(:reactions) do
      add :type, :integer
      add :comment_id, references(:comments, on_delete: :nothing)
      add :user_id, references(:users, on_delete: :nothing)
      timestamps()
    end

    create index(:reactions, [:comment_id])
    create index(:reactions, [:user_id])
  end
end
