defmodule Collaboration.Contributions.Idea do
  use Ecto.Schema
  import Ecto.Changeset

  schema "ideas" do

    field :desc, :string
    field :fake_rating, :float, default: 4.2
    field :fake_raters, :integer, default: 0
    field :public, :boolean, default: false
    field :title, :string
    timestamps()

    has_many :comments, Collaboration.Contributions.Comment, on_delete: :delete_all
    has_many :ratings, Collaboration.Contributions.Rating, on_delete: :delete_all

    belongs_to(:topic, Collaboration.Contributions.Topic)
    belongs_to(:user, Collaboration.Coherence.User, type: :binary_id)
  end

  @doc false
  def changeset(idea, attrs) do
    idea
    |> cast(attrs, [:public, :title, :desc, :fake_rating, :fake_raters])
    |> validate_required([:title])
    |> validate_length(:title, min: 5, max: 80)
    |> validate_length(:desc, max: 2000)
    |> validate_number(
      :fake_rating,
      greater_than_or_equal_to: 1,
      less_than_or_equal_to: 5
    )
    |> validate_number(:fake_raters, greater_than_or_equal_to: 0)
  end
end
