defmodule Collaboration.Contributions.Idea do
  use Ecto.Schema
  import Ecto.Changeset

  schema "ideas" do
    field :desc, :string
    field :title, :string
    timestamps()
    has_many :comments, Collaboration.Contributions.Comment, on_delete: :delete_all
    belongs_to :topic, Collaboration.Contributions.Topic
    belongs_to :user, Collaboration.Coherence.User, type: :binary_id
  end

  @doc false
  def changeset(idea, attrs) do
    idea
    |> cast(attrs, [:title, :desc])
    |> validate_required([:title])
    |> validate_length(:title, min: 5, max: 80)
    |> validate_length(:desc, max: 3000)
  end
end
