defmodule CollaborationWeb.IdeaView do
  use CollaborationWeb, :view

  def idea_id(conn), do: String.to_integer conn.params["id"]
  def topic_id(conn), do: String.to_integer conn.params["topic_id"]

  def active?(idea, idea_id) do
    if idea.id === idea_id, do: " table-active"
  end

  # calculates rating for an idea
  defp calc_rating(rating, raters, my_rating) do
    all_raters = if my_rating, do: raters + 1, else: raters
    rating = cond do
      all_raters === 0 ->
        nil
      !my_rating ->
        Float.round(rating/1, 2)
      true ->
        Float.round((rating * raters + my_rating) / all_raters, 2)
    end
    {rating, all_raters}
  end

  # used for displaying list of ideas
  # calculates rating
  def render("idea-basic.json", %{idea: i}) do
    my_rating = Map.get i, :my_rating
    { rating, raters } = calc_rating(i.fake_rating, i.fake_raters, my_rating)
    %{
      id: i.id,
      title: i.title,
      created: NaiveDateTime.to_iso8601(i.created) <> "Z",
      comment_count: i.comment_count,
      rating: rating,
      raters: raters,
      user_id: i.user_id
    }
  end

  # used for displaying idea with all its details (likes,...)
  def render("idea.json", %{idea: i}) do
    my_rating = Map.get i, :my_rating
    { rating, raters } = calc_rating(i.fake_rating, i.fake_raters, my_rating)

    %{
      id: i.id,
      author: i.author,
      created: NaiveDateTime.to_iso8601(i.created) <> "Z",
      desc: i.desc,
      my_rating: my_rating,
      rating: rating,
      raters: raters,
      title: i.title,
      user_id: i.user_id
    }
  end
end
