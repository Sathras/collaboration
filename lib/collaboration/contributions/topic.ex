defmodule Collaboration.Contributions.Topic do
  use Ecto.Schema
  import Ecto.Changeset

  schema "topics" do
    field :desc, :string
    field :short_desc, :string
    field :short_title, :string
    field :title, :string
    field :featured, :boolean, default: false
    field :visible, :integer, default: 0
    timestamps()
    has_many :ideas, Collaboration.Contributions.Idea, on_delete: :delete_all
  end

  @doc false
  def changeset(topic, attrs) do
    fields = ~w(title short_title desc featured visible short_desc)a
    topic
    |> cast(attrs, fields)
    |> validate_required(fields)
  end
end
