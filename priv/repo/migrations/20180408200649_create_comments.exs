defmodule Collaboration.Repo.Migrations.CreateComments do
  use Ecto.Migration

  def change do
    create table(:comments) do
      add :text, :string
      add :idea_id, references(:ideas)
      add :user_id, references(:users, type: :binary_id)
      timestamps()
    end
  end
end
