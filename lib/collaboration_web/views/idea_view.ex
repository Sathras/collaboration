defmodule CollaborationWeb.IdeaView do
  use CollaborationWeb, :view

  def render("idea.json", %{idea: i}) do
    %{
      author: i.user.name,
      id: i.id,
      js_id: "idea_#{i.id}",
      title: i.title,
      desc: i.desc,
      created: NaiveDateTime.to_iso8601(i.inserted_at)<>"Z",
      comment_count: Enum.count(i.comments),
      rating: rating(i),
      raters: i.fake_raters + Enum.count(i.ratings),
      fake_raters: i.fake_raters,
      fake_rating: i.fake_rating
    }
  end

  def like_label(conn, comment) do
    user_ids = Enum.map(comment.likes, fn(u) -> u.id end)
    if Enum.member? user_ids, Coherence.current_user(conn).id do
      "Unlike"
    else
      "Like"
    end
  end

  def rating(idea) do
    ratings = Enum.map(idea.ratings, fn r -> r.rating end)
    r_count = Enum.count(idea.ratings)
    f_count = idea.fake_raters
    f_rating = idea.fake_rating
    if r_count == 0 do
      if f_count > 0, do: f_rating, else: nil
    else
      r_rating = Enum.sum(ratings) / r_count
      Float.round((r_rating * r_count + f_rating * f_count) / (r_count + f_count), 2)
    end
  end

  def likes(comment), do: Enum.count(comment.likes) + comment.fake_likes
end
