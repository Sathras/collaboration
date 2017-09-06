defmodule Collaboration.CommentView do
  use Collaboration.Web, :view
  alias Collaboration.UserView
  alias Collaboration.ReactionView
  alias Phoenix.View

  def render("comment.json", %{comment: c}) do
    %{
      id: c.id,
      inserted_at: c.inserted_at,
      text: c.text,
      user: UserView.displayName(c.user),
      likes: View.render_one(c.reactions, ReactionView, "likes.json")
    }
  end
end
