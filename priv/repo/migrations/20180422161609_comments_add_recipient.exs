defmodule Collaboration.Repo.Migrations.CommentsAddRecipient do
  use Ecto.Migration

  def change do
    alter table(:comments) do
      add(
        :recipient_id,
        references(:users, type: :binary_id, on_delete: :delete_all)
      )
    end
  end
end
