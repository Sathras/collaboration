defmodule Collaboration.Repo.Migrations.Contributions do
  use Ecto.Migration

  def change do
    create table(:topics) do
      add :title, :string
      add :desc, :text
      add :featured, :boolean, default: false, null: false
      timestamps()
    end

    create table(:ideas) do
      add :text, :text, null: false
      add :fake_rating, :float
      add :fake_raters, :integer, default: 0, null: false
      add :c1, :integer, default: 0, null: false
      add :c2, :integer, default: 0, null: false
      add :c3, :integer, default: 0, null: false
      add :c4, :integer, default: 0, null: false
      add :c5, :integer, default: 0, null: false
      add :c6, :integer, default: 0, null: false
      add :c7, :integer, default: 0, null: false
      add :c8, :integer, default: 0, null: false
      add :topic_id, references(:topics, on_delete: :delete_all), null: false
      add :user_id, references(:users, on_delete: :delete_all), null: false
      timestamps()
    end

    create table(:comments) do
      add :text, :text
      add :fake_likes, :integer, null: false, default: 0
      add :c1, :integer, default: 0, null: false
      add :c2, :integer, default: 0, null: false
      add :c3, :integer, default: 0, null: false
      add :c4, :integer, default: 0, null: false
      add :c5, :integer, default: 0, null: false
      add :c6, :integer, default: 0, null: false
      add :c7, :integer, default: 0, null: false
      add :c8, :integer, default: 0, null: false
      add :idea_id, references(:ideas, on_delete: :delete_all)
      add :user_id, references(:users, on_delete: :delete_all)
      timestamps()
    end

    create table(:ratings) do
      add :user_id, references(:users, on_delete: :delete_all)
      add :idea_id, references(:ideas, on_delete: :delete_all)
      add :rating, :integer
    end
    create unique_index(:ratings, [:user_id, :idea_id])

    create table(:likes) do
      add :user_id, references(:users, on_delete: :delete_all)
      add :comment_id, references(:comments, on_delete: :delete_all)
      timestamps()
    end

    create unique_index(:likes, [:user_id, :comment_id])
  end
end
