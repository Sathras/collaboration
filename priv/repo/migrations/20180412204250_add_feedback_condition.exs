defmodule Collaboration.Repo.Migrations.AddFeedbackCondition do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add(:feedback, :boolean)
    end
  end
end
