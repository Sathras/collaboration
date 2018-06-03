defmodule Collaboration.Contributions.Comment do
  use Ecto.Schema
  import Ecto.Changeset

  schema "comments" do
    field :fake_likes, :integer, null: false, default: 0
    field :text, :string
    belongs_to :idea,       Collaboration.Contributions.Idea
    belongs_to :user,       Collaboration.Coherence.User, type: :binary_id
    belongs_to :recipient,  Collaboration.Coherence.User, type: :binary_id

    many_to_many :likes,   Collaboration.Coherence.User, join_through: "likes",
                           on_replace: :delete, on_delete: :delete_all
    timestamps()
  end

  @doc false
  def changeset(comment, attrs) do
    comment
    |> cast(attrs, [:text, :fake_likes])
    |> validate_required([:text])
    |> validate_number(:fake_likes, greater_than_or_equal_to: 0)
  end
end
