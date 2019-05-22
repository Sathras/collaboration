defmodule Collaboration.Contributions.Like do
  use Ecto.Schema
  import Ecto.Changeset

  schema "likes" do
    belongs_to :comment, Collaboration.Contributions.Comment
    belongs_to :user, Collaboration.Accounts.User
    timestamps()
  end

  @doc false
  def changeset(comment, params \\ %{}) do
    comment
    |> cast(params, [:comment_id, :user_id])
    |> validate_required([:comment_id, :user_id])
  end
end
