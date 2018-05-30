defmodule Collaboration.Repo.Migrations.UserAddFeedbackCondition do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :condition, :integer
      remove :feedback
    end
  end
end
