defmodule Collaboration.IdeaView do
  use Collaboration.Web, :view

  def render("idea.json", %{idea: i}) do
    %{
      id: i.id,
      title: i.title,
      description: i.description,
      comments: render_many(i.comments, Collaboration.CommentView, "comment.json"),
      user: render_one(i.user, Collaboration.UserView, "user-public.json")
    }
  end
end
