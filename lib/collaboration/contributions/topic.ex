defmodule Collaboration.Contributions.Topic do
  use Ecto.Schema
  import Ecto.Changeset

  schema "topics" do
    field(:desc, :string)
    field(:short_desc, :string)
    field(:short_title, :string)
    field(:title, :string)
    field(:featured, :boolean, default: false)
    field(:open, :boolean, default: true)
    field(:published, :boolean, default: false)
    timestamps()
    has_many(:ideas, Collaboration.Contributions.Idea, on_delete: :delete_all)
  end

  @doc false
  def changeset(topic, attrs) do
    topic
    |> cast(attrs, [
      :title,
      :short_title,
      :desc,
      :featured,
      :published,
      :open,
      :short_desc
    ])
    |> validate_required([
      :title,
      :short_title,
      :desc,
      :featured,
      :published,
      :open,
      :short_desc
    ])
  end
end
