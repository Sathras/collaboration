defmodule Collaboration.Repo.Migrations.CreateTopic do
  use Ecto.Migration

  def change do
    create table(:topics) do
      add :title, :string
      add :menutitle, :string
      add :shortdesc, :string   # for overview
      add :longdesc, :string    # for topic page
      timestamps()
    end
  end
end
