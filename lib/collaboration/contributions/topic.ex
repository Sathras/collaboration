defmodule Collaboration.Contributions.Topic do
  use Ecto.Schema
  import Ecto.Changeset

  schema "topics" do
    field :desc,        :string
    field :short_desc,  :string
    field :short_title, :string
    field :slug,        :string
    field :title,       :string
    field :featured,    :boolean, default: false
    field :open,        :boolean, default: true
    field :published,   :boolean, default: false
    timestamps()
    has_many :ideas, Collaboration.Contributions.Idea
  end

  @doc false
  def changeset(topic, attrs) do
    topic
    |> cast(attrs, [:slug, :title, :short_title, :desc, :featured, :published, :open, :short_desc])
    |> validate_required([:slug, :title, :short_title, :desc, :featured, :published, :open, :short_desc])
    |> sanitize(:short_desc)
    |> sanitize(:desc)
    |> unique_constraint(:slug)
  end

  defp sanitize(changeset, field) do
    if Map.has_key?(changeset.changes, field) do
      changed_field = Map.get changeset.changes, field
      put_change changeset, field, HtmlSanitizeEx.basic_html(changed_field)
    else
      changeset
    end
  end
end
