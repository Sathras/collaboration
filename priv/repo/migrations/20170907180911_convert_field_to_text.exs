defmodule Collaboration.Repo.Migrations.ConvertFieldToText do
  use Ecto.Migration

  def change do
    alter table(:ideas) do
      modify :description, :text
    end

    alter table(:comments) do
      modify :text, :text
    end
  end
end
