defmodule Collaboration.Reaction do
  use Collaboration.Web, :model

  @timestamps_opts [type: :utc_datetime, usec: false]

  schema "reactions" do
    field :type, :integer
    belongs_to :comment, Collaboration.Comment
    belongs_to :user, Collaboration.User
    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, ~w(type))
    |> validate_required([:type])
  end
end
