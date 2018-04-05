defmodule Collaboration.Contributions.Topic do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "topics" do
    field :desc, :string
    field :open, :boolean, default: true
    field :published, :boolean, default: false
    field :short_desc, :string
    field :short_title, :string
    field :title, :string
    timestamps()
  end

  @doc false
  def changeset(topic, attrs) do
    topic
    |> cast(attrs, [:title, :short_title, :desc, :published, :open, :short_desc])
    |> validate_required([:title, :short_title, :desc, :published, :open, :short_desc])
  end
end
