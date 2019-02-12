defmodule Collaboration.Contributions.Comment do
  use Ecto.Schema
  import Ecto.Changeset

  schema "comments" do
    field :fake_likes, :integer, null: false, default: 0
    field :text, :string
    field :c1, :integer, default: 0
    field :c2, :integer, default: 0
    field :c3, :integer, default: 0
    field :c4, :integer, default: 0
    field :c5, :integer, default: 0
    field :c6, :integer, default: 0
    field :c7, :integer, default: 0
    field :c8, :integer, default: 0
    belongs_to :idea,       Collaboration.Contributions.Idea
    belongs_to :user,       Collaboration.Coherence.User
    many_to_many :likes,    Collaboration.Coherence.User, join_through: "likes",
                            on_replace: :delete, on_delete: :delete_all
    timestamps()
  end

  @doc false
  def changeset(comment, attrs) do
    comment
    |> cast(attrs, ~w(text fake_likes c1 c2 c3 c4 c5 c6 c7 c8 idea_id user_id)a)
    |> validate_required([:text])
    |> validate_number(:fake_likes, greater_than_or_equal_to: 0)
  end
end
