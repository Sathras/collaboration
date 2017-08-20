defmodule Collaboration.Topic do
  use Collaboration.Web, :model

  schema "topics" do
    field :title, :string
    field :menutitle, :string
    field :shortdesc, :string   # for overview
    field :longdesc, :string    # for topic page
    field :order, :integer
    field :hidden, :boolean, default: false
    field :closed, :boolean, default: false
    has_many :ideas, Collaboration.Idea
    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, ~w(title menutitle shortdesc longdesc order hidden closed))
    |> validate_required([:title, :menutitle, :shortdesc, :longdesc, :hidden, :closed])
    |> validate_length(:title, min: 5, max: 30)
    |> validate_length(:menutitle, min: 2, max: 12)
    |> validate_number(:order, greater_than_or_equal_to: 0)
    |> unique_constraint(:title)
    |> unique_constraint(:menutitle)
  end
end
