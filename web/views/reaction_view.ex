defmodule Collaboration.ReactionView do
  use Collaboration.Web, :view

  def render("likes.json", %{reaction: reaction}) do
    reaction
    |> Enum.filter(fn(r) -> r.type == 0 end)  # use only likes
    |> Enum.map(fn(r) -> r.user_id end)       # create a list of user_ids
  end
end
