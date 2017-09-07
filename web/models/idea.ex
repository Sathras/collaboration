defmodule Collaboration.Idea do
  use Collaboration.Web, :model

  @timestamps_opts [type: :utc_datetime, usec: false]

  schema "ideas" do
    field :title, :string
    field :description, :string
    has_many :comments, Collaboration.Comment
    belongs_to :topic, Collaboration.Topic
    belongs_to :user, Collaboration.User
    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, ~w(title description))
    |> validate_required([:title, :description])
    |> validate_length(:title, min: 5, max: 40)
    |> validate_length(:description, min: 5, max: 100000)
  end
end
