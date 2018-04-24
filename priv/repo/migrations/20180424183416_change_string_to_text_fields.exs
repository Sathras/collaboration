defmodule Collaboration.Repo.Migrations.ChangeStringToTextFields do
  use Ecto.Migration

  def change do
    alter table(:topics) do
      modify :short_desc, :text
      modify :desc, :text
    end

    alter table(:ideas) do
      modify :desc, :text
    end

    alter table(:comments) do
      modify :text, :text
    end
  end
end
