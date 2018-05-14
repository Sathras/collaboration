defmodule Collaboration.Repo.Migrations.AddPublicFlags do
  use Ecto.Migration

  def change do
    alter table(:ideas) do
      add :public, :boolean, null: false, default: false
    end

    alter table(:comments) do
      add :public, :boolean, null: false, default: false
    end
  end
end
