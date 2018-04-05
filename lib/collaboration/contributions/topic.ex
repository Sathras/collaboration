defmodule Collaboration.Contributions.Topic do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
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
  end

  @doc false
  def changeset(topic, attrs) do
    topic
    |> cast(attrs, [:slug, :title, :short_title, :desc, :featured, :published, :open, :short_desc])
    |> validate_required([:slug, :title, :short_title, :desc, :featured, :published, :open, :short_desc])
    |> unique_constraint(:slug)
  end
end
