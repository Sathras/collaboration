defmodule CollaborationWeb.IdeaView do
  use CollaborationWeb, :view

  alias Phoenix.View
  alias CollaborationWeb.CommentView

  def base_rating(rating, raters) do
    cond do
      raters === 0 ->  "base0"
      rating >= 4.5 -> "base5"
      rating >= 3.5 -> "base4"
      rating >= 2.5 -> "base3"
      rating >= 1.5 -> "base2"
      true ->          "base1"
    end
  end

  def edit?(changeset), do: Map.has_key?(changeset, :id)

  def idea_id(conn) do
    if Map.has_key?(conn.params, "id"),
      do: Map.get(conn.params, "id") |> String.to_integer,
      else: nil
  end

  def idea_class(idea) do
    if idea.remaining > 0, do: "idea d-none", else: "idea"
  end

  def topic_id(conn), do: Map.get(conn.params, "topic_id", conn.params["id"])

  def active?(idea, idea_id) do
    if idea.id === idea_id, do: " table-active"
  end

  # calculates rating for an idea
  def calc_rating(rating, raters, my_rating, old_rating \\ nil) do
    all_raters = if my_rating && !old_rating, do: raters + 1, else: raters
    rating = cond do
      old_rating ->
        Float.round((rating * raters + my_rating - old_rating) / all_raters, 2)
      all_raters === 0 ->
        nil
      !my_rating ->
        Float.round(rating/1, 2)
      my_rating && !rating ->
        Float.round(my_rating / all_raters, 2)
      true ->
        Float.round((rating * raters + my_rating) / all_raters, 2)
    end
    {rating, all_raters}
  end

  def render("idea.json", %{idea: i, user: u}) do

    condition = String.to_atom "c#{u.condition}"
    created = if u.condition == 0 || i.user_id == u.id,
      do: i.inserted_at,
      else: NaiveDateTime.add(u.inserted_at, Map.get(i, condition))

    remaining = NaiveDateTime.diff created, NaiveDateTime.utc_now()

    my_rating = if u, do: Enum.find(i.ratings, & &1.user_id === u.id), else: nil
    my_rating = if my_rating, do: Map.get(my_rating, :rating), else: nil
    { rating, raters } = calc_rating(i.fake_rating, i.fake_raters, my_rating)

    comments = i.comments
    |> View.render_many(CommentView, "comment.json", user: u)
    |> Enum.sort_by(fn(c) -> c.created end)

    %{
      id: i.id,
      author: i.user,
      comments: comments,
      created: date(created),
      my_rating: my_rating,
      rating: rating,
      raters: raters,
      remaining: remaining,
      text: i.text,
      user_id: i.user_id
    }
  end

  def star(conn, value, idea) do

    label = content_tag :label,
      content_tag(:i, "", class: "fas fa-star pointer")

    color = if idea.my_rating && idea.my_rating >= value,
      do: "text-primary",
      else: "text-muted"

    button label, to: Routes.idea_path(conn, :rate, idea.id, value),
      method: "post",
      class: "btn btn-link #{color} pointer p-0",
      title: "rate #{value} stars",
      data_toggle: "tooltip"
  end

  def unrate_btn(conn, idea_id) do
    tag = content_tag :i, "", class: "fas fa-minus-circle pointer text-danger"
    button tag, to: Routes.idea_path(conn, :unrate, idea_id),
      method: "delete",
      class: "btn btn-link pointer p-0",
      title: "Remove Rating",
      data_toggle: "tooltip"
  end
end
