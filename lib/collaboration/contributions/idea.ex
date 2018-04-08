defmodule Collaboration.Contributions.Idea do
  use Ecto.Schema
  import Ecto.Changeset

  schema "ideas" do
    field :desc, :string
    field :title, :string
    timestamps()
    belongs_to :topic, Collaboration.Contributions.Topic
    belongs_to :user, Collaboration.Coherence.User, type: :binary_id
  end

  @doc false
  def changeset(idea, attrs) do
    idea
    |> cast(attrs, [:title, :desc])
    |> validate_required([:title, :desc])
    |> validate_required([:title, :desc])
    |> validate_length(:title, min: 5, max: 80)
    |> validate_length(:desc, min: 15, max: 3000)
  end
end
