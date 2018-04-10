defmodule Collaboration.Repo.Migrations.CreateRatings do
  use Ecto.Migration

  def change do
    create table(:ratings) do
      add :user_id, references(:users, type: :binary_id)
      add :idea_id, references(:ideas)
      add :rating, :integer
    end

    create unique_index(:ratings, [:user_id, :idea_id])
  end
end
