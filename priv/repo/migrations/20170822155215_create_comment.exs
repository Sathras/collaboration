defmodule Collaboration.Repo.Migrations.CreateComment do
  use Ecto.Migration

  def change do
    create table(:comments) do
      add :text, :string
      add :idea_id, references(:ideas, on_delete: :nothing)
      add :user_id, references(:users, on_delete: :nothing)
      timestamps()
    end

    create index(:comments, [:idea_id])
    create index(:comments, [:user_id])
  end
end
