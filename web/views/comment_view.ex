defmodule Collaboration.CommentView do
  use Collaboration.Web, :view
  alias Collaboration.UserView

  def render("comment.json", %{comment: c}) do
    %{
      id: c.id,
      inserted_at: c.inserted_at,
      text: c.text,
      user: UserView.displayName(c.user)
    }
  end
end
