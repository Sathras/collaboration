defmodule CollaborationWeb.CommentView do
  use CollaborationWeb, :view

  def thumbsUp?(comment, user) do
    if comment.likes > 0 || (user && (comment.id !== user.id || user.admin)),
    do: true, else: false
  end

  def render("comment.json", %{comment: c}) do
    liked = !!c.liked
    likes = if liked, do: c.likes + 1, else: c.likes
    %{
      id: c.id,
      author: c.author,
      created: NaiveDateTime.to_iso8601(c.created) <> "Z",
      text: c.text,
      liked: !!c.liked,
      likes: likes,
      user_id: c.user_id
    }
  end
end
