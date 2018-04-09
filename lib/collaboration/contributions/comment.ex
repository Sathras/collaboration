defmodule Collaboration.Contributions.Comment do
  use Ecto.Schema
  import Ecto.Changeset

  schema "comments" do
    field :text, :string
    timestamps()
    belongs_to :idea, Collaboration.Contributions.Idea
    belongs_to :user, Collaboration.Coherence.User, type: :binary_id
  end

  @doc false
  def changeset(comment, attrs) do
    comment
    |> cast(attrs, [:text])
    |> validate_required([:text])
  end
end
