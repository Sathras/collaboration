defmodule CollaborationWeb.TopicView do
  use CollaborationWeb, :view

  def ideaTitle(idea) do
    if idea.my_idea?, do: content_tag(:u, idea.title), else: idea.title
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
