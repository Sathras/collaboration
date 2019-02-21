defmodule Collaboration.Repo.Migrations.Accounts do
  @moduledoc """
  users belong to a certain condition
  0 admin and peer users
  1 DI(L) F(L) BI(L)    DI = Direct Interaction
  2 DI(L) F(H) BI(L)    F  = Friendliness
  3 DI(H) F(L) BI(L)    BI = Bot Interaction
  4 DI(H) F(H) BI(L)    L  = Low
  5 DI(L) F(L) BI(H)    H  = High
  6 DI(L) F(H) BI(H)
  7 DI(H) F(L) BI(H)
  8 DI(H) F(H) BI(H)
  """
  use Ecto.Migration

  def change do

    create table(:users) do
      add :name, :string, null: false
      add :condition, :integer, null: false
      timestamps()
      add :completed_at, :naive_datetime
    end

    create table(:credentials) do
      add :username, :string, null: false
      add :password_hash, :string, null: false
      add :user_id, references(:users, on_delete: :delete_all), null: false
      timestamps()
    end

    create unique_index(:credentials, [:username])
    create index(:credentials, [:user_id])
  end
end
