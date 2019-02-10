defmodule CollaborationWeb.CommentView do
  use CollaborationWeb, :view

  def comment_class(comment) do
    if comment.remaining > 0, do: "comment d-none", else: "comment"
  end

  def render("comment.json", %{comment: c, user: u}) do

    created = if u.condition == 0 || c.user_id == u.id do
      c.inserted_at
    else
      condition = String.to_atom "c#{u.condition}"
      NaiveDateTime.add(u.inserted_at, Map.get(c, condition))
    end

    remaining = NaiveDateTime.diff created, NaiveDateTime.utc_now()

    liked = !!Enum.find(c.likes, & &1.id === u.id)
    likes = if liked, do: c.fake_likes + 1, else: c.fake_likes

    %{
      id: c.id,
      author: c.user,
      created: date(created),
      text: c.text,
      liked: liked,
      likes: likes,
      remaining: remaining,
      user_id: c.user_id
    }
  end
end
