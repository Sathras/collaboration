defmodule CollaborationWeb.CommentView do
  use CollaborationWeb, :view

  def render("comment.json", %{comment: c, user: u}) do
    liked = !!Enum.find(c.likes, & &1.id === u.id)
    likes = if liked, do: c.fake_likes + 1, else: c.fake_likes
    %{
      id: c.id,
      author: c.user.name,
      admin: c.user.admin,
      created: NaiveDateTime.to_iso8601(c.inserted_at) <> "Z",
      text: c.text,
      liked: liked,
      likes: likes,
      user_id: c.user_id
    }
  end
end
