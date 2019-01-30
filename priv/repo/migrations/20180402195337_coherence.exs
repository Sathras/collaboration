defmodule Collaboration.Repo.Migrations.Coherence do
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
      add :condition, :integer, default: 0, null: false
      add :completed, :boolean, null: false, default: false
      add :feedback_sequence, :integer
      add :name, :string
      add :email, :string
      add :remember_created_at, :utc_datetime
      add :password_hash, :string
      add :reset_password_token, :string
      add :reset_password_sent_at, :utc_datetime
      add :sign_in_count, :integer, default: 0
      add :last_sign_in_at, :utc_datetime
      add :current_sign_in_at, :utc_datetime
      add :current_sign_in_ip, :string
      add :last_sign_in_ip, :string
      timestamps()
    end

    create unique_index(:users, [:email])

    create table(:invitations) do
      add :name, :string
      add :email, :string
      add :token, :string
      timestamps()
    end

    create unique_index(:invitations, [:email])
    create index(:invitations, [:token])

    create table(:rememberables) do
      add :series_hash, :string
      add :token_hash, :string
      add :token_created_at, :utc_datetime
      add :user_id, references(:users, on_delete: :delete_all)
      timestamps()
    end

    create index(:rememberables, [:user_id])
    create index(:rememberables, [:series_hash])
    create index(:rememberables, [:token_hash])
    create unique_index(:rememberables, [:user_id, :series_hash, :token_hash])
  end
end
