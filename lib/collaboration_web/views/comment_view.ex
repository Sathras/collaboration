defmodule CollaborationWeb.CommentView do
  use CollaborationWeb, :view

  def render("comment.json", %{comment: c, current_user: user_id}) do
    liked_ids = Enum.map(c.likes, fn l -> l.name end)
    liked = if user_id, do: Enum.member?(liked_ids, user_id), else: false

    %{
      author: c.user.name,
      recipient_id: c.recipient_id,
      id: c.id,
      text: c.text,
      created: NaiveDateTime.to_iso8601(c.inserted_at)<>"Z",
      fake_likes: c.fake_likes,
      likes: c.fake_likes + Enum.count(liked_ids),
      liked: liked
    }
  end
end