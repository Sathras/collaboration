defmodule Collaboration.Contributions.Topic do
  use Ecto.Schema
  import Ecto.Changeset

  schema "topics" do
    field :desc, :string
    field :title, :string
    field :featured, :boolean, default: false
    timestamps()
    has_many :ideas, Collaboration.Contributions.Idea, on_delete: :delete_all
  end

  @doc false
  def changeset(topic, attrs) do
    topic
    |> cast(attrs, [:title, :desc, :featured])
    |> validate_required([:title, :desc])
  end
end
