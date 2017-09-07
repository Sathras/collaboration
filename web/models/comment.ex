defmodule Collaboration.Comment do
  use Collaboration.Web, :model

  @timestamps_opts [type: :utc_datetime, usec: false]

  schema "comments" do
    field :text, :string
    belongs_to :idea, Collaboration.Idea
    belongs_to :user, Collaboration.User
    has_many :reactions, Collaboration.Reaction
    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, ~w(text))
    |> validate_required([:text])
    |> validate_length(:text, min: 2, max: 10000)
  end
end
