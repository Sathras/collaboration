defmodule Collaboration.Repo.Migrations.Desctotext do
  use Ecto.Migration

  def change do
    alter table(:topics) do
      modify :shortdesc, :text
      modify :longdesc, :text
    end
  end
end
