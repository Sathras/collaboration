defmodule Collaboration.Repo.Migrations.AddFakeLikes do
  use Ecto.Migration

  def change do
    alter table(:comments) do
      add(:fake_likes, :integer, null: false, default: 0)
    end
  end
end
