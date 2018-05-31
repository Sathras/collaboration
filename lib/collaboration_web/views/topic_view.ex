defmodule CollaborationWeb.TopicView do
  use CollaborationWeb, :view

  def active_idea(idea, current_idea) do
    if idea.id === current_idea, do: " table-active"
  end

  def my_rating(idea, my_ratings) do
    rating = Enum.find(my_ratings, fn(x) -> x.idea_id == idea.id end)
    if rating, do: rating.rating, else: nil
  end

  def show_rating?(idea, rating) do
    me = if rating, do: true, else: idea.raters > 0
  end

  # only uses fake ratings and own rating
  def rating(idea, my_rating) do
    cond do
      idea.fake_raters === 0 && !my_rating -> ""
      idea.fake_raters === 0 && my_rating -> "#{my_rating}.00"
      !my_rating ->
        :erlang.float_to_binary(idea.fake_rating*1, [decimals: 2])
      my_rating ->
        :erlang.float_to_binary(
        (idea.fake_rating * idea.fake_raters + my_rating)
        / (idea.fake_raters + 1), [decimals: 2])
    end
  end

  def raters(idea, my_rating) do
    if my_rating, do: idea.fake_raters + 1, else: idea.fake_raters
  end

  def ideaTitle(idea, user) do
    if user && idea.user_id === user.id do
      content_tag :u, idea.title
    else
      idea.title
    end
  end

  def iconFeatured(topic) do
    class = if topic.featured, do: "text-primary", else: "text-muted"
    content_tag :i, "",
      class: "fas fa-star #{class}",
      data_id: topic.id,
      data_param: "featured",
      data_value: "#{topic.featured}",
      drab_click: "toggle"
  end

  def iconOpen(topic) do
    class = if topic.open, do: "fa-unlock-alt text-success", else: "fa-lock"
    content_tag :i, "",
      class: "fas #{class}",
      data_id: topic.id,
      data_param: "open",
      data_value: "#{topic.open}",
      drab_click: "toggle"
  end

  def iconPublished(topic) do
    class = if topic.published, do: "fa-eye", else: "fa-eye-slash text-muted"
    content_tag :i, "",
      class: "fas #{class}",
      data_id: topic.id,
      data_param: "published",
      data_value: "#{topic.published}",
      drab_click: "toggle"
  end

  def newTopicLink(conn), do:
    admin?(conn) && link gettext("New Topic"),
      to: topic_path(conn, :new),
      class: "float-right btn btn-outline-dark"
end
