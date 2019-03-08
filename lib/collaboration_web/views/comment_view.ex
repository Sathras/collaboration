defmodule CollaborationWeb.CommentView do
  use CollaborationWeb, :view

  def comment_class(comment) do
    if future(comment.inserted_at), do: "comment d-none", else: "comment"
  end

  def like_button(comment) do
    text = if comment.liked, do: "Unlike", else: "Like"
    content_tag :a, text,
      class: "like",
      href: "#",
      data_comment_id: comment.id
  end

  def render("comment.json", %{comment: c, user: u}) do

    inserted_at = if u.condition == 0 || c.user_id == u.id, do: c.inserted_at,
    else: NaiveDateTime.add(u.inserted_at, Map.get(c, condition(u)))

    liked = if Ecto.assoc_loaded?(c.likes),
      do: !!Enum.find(c.likes, & &1.id === u.id),
      else: false
    likes = if liked, do: c.fake_likes + 1, else: c.fake_likes

    # if user was not preloaded check if id matches current user
    user = cond do
      Ecto.assoc_loaded?(c.user) -> c.user.name
      c.user_id == u.id -> u.name
      true -> "Unknown"
    end

    %{
      id: c.id,
      inserted_at: inserted_at,
      delay: Map.get(c, condition(u)),
      text: c.text,
      liked: liked,
      likes: likes,
      idea_id: c.idea_id,
      user_id: c.user_id,
      user: user
    }
  end
end
