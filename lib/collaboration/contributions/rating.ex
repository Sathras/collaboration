defmodule Collaboration.Contributions.Rating do
  use Ecto.Schema
  import Ecto.Changeset

  schema "ratings" do
    field :rating, :integer
    belongs_to :idea, Collaboration.Contributions.Idea
    belongs_to :user, Collaboration.Accounts.User
  end

  @doc false
  def changeset(rating, attrs) do
    fields = ~w(rating idea_id)a
    rating
    |> cast(attrs, fields)
    |> validate_required(fields)
    |> validate_number(:rating, greater_than: 0, less_than: 6)
  end
end
