defmodule CollaborationWeb.CommentView do
  use CollaborationWeb, :view

  def render("comment.json", %{comment: c, user: u}) do

    created = if u.condition == 0 || c.user_id == u.id do
      date c.inserted_at
    else
      condition = String.to_atom "c#{u.condition}"
      date NaiveDateTime.add(u.inserted_at, Map.get(c, condition))
    end

    liked = !!Enum.find(c.likes, & &1.id === u.id)
    likes = if liked, do: c.fake_likes + 1, else: c.fake_likes

    %{
      id: c.id,
      author: c.user,
      created: created,
      text: c.text,
      liked: liked,
      likes: likes,
      user_id: c.user_id
    }
  end
end
