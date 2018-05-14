defmodule Collaboration.Contributions.Rating do
  use Ecto.Schema
  import Ecto.Changeset

  schema "ratings" do
    field(:rating, :integer)
    belongs_to(:idea, Collaboration.Contributions.Idea)
    belongs_to(:user, Collaboration.Coherence.User, type: :binary_id)
  end

  @doc false
  def changeset(rating, attrs) do
    rating
    |> cast(attrs, [:rating])
    |> validate_required([:rating])
    |> validate_number(:rating, greater_than: 0, less_than: 6)
  end
end
