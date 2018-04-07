defmodule Collaboration.Contributions.Idea do
  use Ecto.Schema
  import Ecto.Changeset


  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "ideas" do
    field :desc, :string
    field :title, :string
    timestamps()
    belongs_to :topic, Collaboration.Contributions.Topic
    belongs_to :user, Collaboration.Coherence.User
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
