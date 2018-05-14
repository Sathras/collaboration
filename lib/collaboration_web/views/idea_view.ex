defmodule CollaborationWeb.IdeaView do
  use CollaborationWeb, :view

  def render("idea.json", %{idea: i, user: user}) do
    user_id = if is_map(user), do: user.id, else: nil
    admin = if is_map(user), do: user.admin, else: false

    comments = cond do
      admin ->
        i.comments
      user_id ->
        Enum.filter(i.comments, fn c -> c.public || c.recipient_id == user_id end)
      true ->
        Enum.filter(i.comments, fn c -> c.public end)
    end

    %{
      author: i.user.name,
      user_id: i.user.id,
      id: i.id,
      row_id: "idea_#{i.id}",
      title: i.title,
      topic_id: i.topic_id,
      desc: i.desc,
      created: NaiveDateTime.to_iso8601(i.inserted_at) <> "Z",
      comment_count: Enum.count(comments),
      public: i.public,
      rating: rating(i),
      raters: i.fake_raters + Enum.count(i.ratings),
      fake_raters: i.fake_raters,
      fake_rating: i.fake_rating,
      my_rating: Map.get(ratings(i.ratings), user_id, nil)
    }
  end

  def like_label(conn, comment) do
    user_ids = Enum.map(comment.likes, fn u -> u.id end)

    if Enum.member?(user_ids, Coherence.current_user(conn).id) do
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

      Float.round(
        (r_rating * r_count + f_rating * f_count) / (r_count + f_count),
        2
      )
    end
  end

  def likes(comment), do: Enum.count(comment.likes) + comment.fake_likes

  defp ratings(ratings) do
    Enum.map(ratings, fn r -> {r.user_id, r.rating} end)
    |> Map.new()
  end
end
