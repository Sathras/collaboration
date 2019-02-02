defmodule CollaborationWeb.TopicView do
  use CollaborationWeb, :view

  def ideaTitle(idea) do
    if idea.my_idea?, do: content_tag(:u, idea.title), else: idea.title
  end

  def iconVisibility( visibility ) do
    class = case visibility do
      3 -> "fas fa-eye"
      2 -> "far fa-smile"
      1 -> "far fa-frown"
      0 -> "fas fa-eye-slash text-muted"
    end
    content_tag :i, "", class: class
  end

  def iconFeatured( conn, topic) do
    IO.inspect conn
    if topic.featured do
      content_tag :i, "", class: "fas fa-star text-primary"
    else
      link content_tag(:i, "", class: "fas fa-star text-muted"),
        to: Routes.topic_path(conn, :feature, topic.id),
        method: "post"
    end
  end
end
