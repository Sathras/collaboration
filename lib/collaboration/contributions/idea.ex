defmodule Collaboration.Contributions.Idea do
  use Ecto.Schema
  import Ecto.Changeset

  schema "ideas" do
    field :text, :string
    field :fake_rating, :float, default: 4.2
    field :fake_raters, :integer, default: 0
    has_many :comments, Collaboration.Contributions.Comment, on_delete: :delete_all
    has_many :ratings, Collaboration.Contributions.Rating, on_delete: :delete_all
    belongs_to :topic, Collaboration.Contributions.Topic
    belongs_to :user, Collaboration.Coherence.User
    timestamps()
  end

  @doc false
  def changeset(idea, attrs) do
    idea
    |> cast(attrs, [:text, :fake_rating, :fake_raters])
    |> validate_required([:text])
    |> validate_length(:text, max: 1200, min: 40)
    |> validate_number(:fake_rating, greater_than_or_equal_to: 1, less_than_or_equal_to: 5)
    |> validate_number(:fake_raters, greater_than_or_equal_to: 0)
  end
end
