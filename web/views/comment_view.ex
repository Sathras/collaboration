defmodule Collaboration.CommentView do
  use Collaboration.Web, :view

  def render("comment.json", %{comment: c}) do
    %{
      id: c.id,
      text: c.text,
      user: c.user.firstname <> " " <> c.user.lastname
    }
  end
end
