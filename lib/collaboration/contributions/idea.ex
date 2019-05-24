defmodule Collaboration.Contributions.Idea do
  use Ecto.Schema
  import Ecto.Changeset

  schema "ideas" do
    field :text, :string
    field :fake_rating, :float, default: 4.2
    field :fake_raters, :integer, default: 0
    field :c1, :integer, default: 0
    field :c2, :integer, default: 0
    field :c3, :integer, default: 0
    field :c4, :integer, default: 0
    field :c5, :integer, default: 0
    field :c6, :integer, default: 0
    field :c7, :integer, default: 0
    field :c8, :integer, default: 0
    has_many :comments, Collaboration.Contributions.Comment,
      on_delete: :delete_all
    has_many :ratings, Collaboration.Contributions.Rating,
      on_delete: :delete_all
    belongs_to :topic, Collaboration.Contributions.Topic
    belongs_to :user, Collaboration.Accounts.User
    timestamps()
  end

  @doc false
  def changeset(idea, attrs) do
    idea
    |> cast(attrs, ~w(text fake_rating fake_raters c1 c2 c3 c4 c5 c6 c7 c8)a)
    |> validate_required([:text])
    |> validate_length(:text, max: 999, min: 40)
    |> validate_number(:c1, [])
    |> validate_number(:c2, [])
    |> validate_number(:c3, [])
    |> validate_number(:c4, [])
    |> validate_number(:c5, [])
    |> validate_number(:c6, [])
    |> validate_number(:c7, [])
    |> validate_number(:c8, [])
    |> validate_number(:fake_rating, greater_than_or_equal_to: 1, less_than_or_equal_to: 5)
    |> validate_number(:fake_raters, greater_than_or_equal_to: 0)
  end

end
