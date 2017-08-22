defmodule Collaboration.Comment do
  use Collaboration.Web, :model

  schema "comments" do
    field :text, :string
    belongs_to :idea, Collaboration.Idea
    belongs_to :user, Collaboration.User
    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, ~w(text))
    |> validate_required([:text])
    |> validate_length(:text, min: 2, max: 500)
  end
end
