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
end
