defmodule CollaborationWeb.TopicView do
  use CollaborationWeb, :view

  def ideaTitle(idea) do
    if idea.my_idea?, do: content_tag(:u, idea.title), else: idea.title
  end

  def iconVisibility ( visibility ) do
    class = case visibility do
      3 -> "fas fa-eye"
      2 -> "far fa-smile"
      1 -> "far fa-frown"
      _ -> "fas eye-slash text-muted"
    end
    content_tag :i, "", class: class
  end

  def iconFeatured ( featured ) do
    color = if featured, do: "primary", else: "muted"
    content_tag :i, "", class: "fas fa-star text-#{color}"
  end
end
