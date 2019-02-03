defmodule CollaborationWeb.IdeaView do
  use CollaborationWeb, :view
  import Collaboration.Coherence.Schemas

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

    created = if u.condition == 0 do
      date i.inserted_at
    else
      condition = String.to_atom "c#{u.condition}"
      date NaiveDateTime.add(u.inserted_at, Map.get(i, condition))
    end

    my_rating = if u, do: Enum.find(i.ratings, & &1.user_id === u.id), else: nil
    my_rating = if my_rating, do: Map.get(my_rating, :rating), else: nil
    { rating, raters } = calc_rating(i.fake_rating, i.fake_raters, my_rating)

    # filter comments to show only those from appropriate condition
    valid_authors = cond do
      !u -> []
      u.condition === 1 -> get_user_ids u.id
      true -> get_user_ids u.id, :peers
      # u.condition === 2 -> get_user_ids(u.id, :peers)
      # u.condition === 3 -> get_user_ids(u.id, :peers)
      # u.condition === 4 -> get_user_ids(u.id, :peers)
    end

    comments = i.comments
    |> Enum.filter(& &1.user_id in valid_authors)
    |> View.render_many(CommentView, "comment.json", user: u)

    %{
      id: i.id,
      author: i.user,
      comments: comments,
      created: created,
      my_rating: my_rating,
      rating: rating,
      raters: raters,
      text: i.text,
      user_id: i.user_id
    }
  end

  def star(value, idea) do
    input = content_tag :input, "",
      id: "star#{value}",
      type: "radio",
      name: "rate",
      checked: value == idea.my_rating,
      value: value

    label = content_tag :label, content_tag(:i, "", class: "fas fa-star"),
      data_rating: value,
      drab_click: "rate(#{idea.id})"

    [ input, label ]
  end
end
