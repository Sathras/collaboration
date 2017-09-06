defmodule Collaboration.Repo.Migrations.Deleteassociations2 do
  use Ecto.Migration

  def change do
    alter table(:reactions) do
      remove :comment_id
      remove :user_id
      add :comment_id, references(:comments, on_delete: :delete_all)
      add :user_id, references(:users, on_delete: :delete_all)
    end

    alter table(:comments) do
      remove :idea_id
      remove :user_id
      add :idea_id, references(:ideas, on_delete: :delete_all)
      add :user_id, references(:users, on_delete: :delete_all)
    end

    alter table(:ideas) do
      remove :topic_id
      remove :user_id
      add :topic_id, references(:topics, on_delete: :delete_all)
      add :user_id, references(:users, on_delete: :delete_all)
    end
  end
end
