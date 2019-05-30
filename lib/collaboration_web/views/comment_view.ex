defmodule CollaborationWeb.CommentView do
  use CollaborationWeb, :view

  def comment_class(comment) do
    if future(comment.inserted_at), do: "comment d-none", else: "comment"
  end

  def like_link(conn, comment) do
    cond do
      current_user(conn).id == comment.user_id -> ""
      true ->
        text = if comment.liked, do: "Unlike", else: "Like"
        link text, to: Routes.comment_path(conn, :toggle_like, comment.id), method: :put
    end
  end

  def render("comment.json", %{comment: c, user: u}) do

    inserted_at = if u.condition == 0 || c.user_id == u.id, do: c.inserted_at,
    else: NaiveDateTime.add(u.inserted_at, Map.get(c, condition(u)))

    liked = if Ecto.assoc_loaded?(c.likes),
      do: !!Enum.find(c.likes, & &1.id === u.id),
      else: false
    likes = if liked, do: c.fake_likes + 1, else: c.fake_likes

    %{
      id: c.id,
      inserted_at: inserted_at,
      delay: Map.get(c, condition(u)),
      text: c.text,
      liked: liked,
      likes: likes,
      idea_id: c.idea_id,
      user_id: c.user_id,
      user: c.user.name
    }
  end
end
