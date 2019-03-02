defmodule CollaborationWeb.CommentView do
  use CollaborationWeb, :view

  def comment_class(comment) do
    if comment.remaining > 0, do: "comment d-none", else: "comment"
  end

  def like_button(comment) do
    text = if comment.liked, do: "Unlike", else: "Like"
    content_tag :a, text,
      class: "like",
      href: "#",
      data_comment_id: comment.id
  end

  def render("comment.json", %{comment: c, user: u}) do

    inserted_at = if u.condition == 0 || c.user_id == u.id do
      c.inserted_at
    else
      condition = String.to_atom "c#{u.condition}"
      NaiveDateTime.add(u.inserted_at, Map.get(c, condition))
    end

    remaining = NaiveDateTime.diff inserted_at, NaiveDateTime.utc_now()

    liked = !!Enum.find(c.likes, & &1.id === u.id)
    likes = if liked, do: c.fake_likes + 1, else: c.fake_likes

    # if user was not preloaded check if id matches current user
    user = cond do
      Ecto.assoc_loaded?(c.user) -> c.user.name
      c.user_id == u.id -> u.name
      true -> "Unknown"
    end

    %{
      id: c.id,
      inserted_at: date(inserted_at),
      text: c.text,
      liked: liked,
      likes: likes,
      remaining: remaining,
      idea_id: c.idea_id,
      user_id: c.user_id,
      user: user
    }
  end
end
