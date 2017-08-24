defmodule Collaboration.CommentView do
  use Collaboration.Web, :view

  def render("comment.json", %{comment: c}) do
    %{
      id: c.id,
      text: c.text,
      user: render_one(c.user, Collaboration.UserView, "user-public.json")
    }
  end
end
