defmodule Collaboration.Repo.Migrations.CreateUser do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :email, :string
      add :firstname, :string
      add :lastname, :string
      add :username, :string, null: false
      add :password_hash, :string
      timestamps()
    end

    create unique_index(:users, [:username])
  end
end
