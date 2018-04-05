defmodule Collaboration.Repo.Migrations.CreateTopics do
  use Ecto.Migration

  def change do
    create table(:topics, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :title, :string
      add :short_title, :string
      add :desc, :string
      add :published, :boolean, default: false, null: false
      add :open, :boolean, default: true, null: false
      add :short_desc, :string
      timestamps()
    end
  end
end
