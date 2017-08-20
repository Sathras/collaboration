defmodule Collaboration.Idea do
  use Collaboration.Web, :model

  schema "ideas" do
    field :title, :string
    field :description, :string
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
  end
end
