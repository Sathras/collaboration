defmodule Collaboration.Repo.Migrations.CreateData do
  use Ecto.Migration

  def change do
    create table(:data) do
      add :field, :string, null: false
      add :value, :text
      timestamps()
    end

    create unique_index(:data, [:field])
  end
end
