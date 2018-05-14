defmodule CollaborationWeb.ViewHelpers do
  @moduledoc """
  Conveniences that can be used in any views and templates.
  """
  use Phoenix.HTML
  import Phoenix.Controller, only: [current_path: 2]

  @type conn :: Plug.Conn.t()

  def badge(topic_id) do
    content_tag(
      :span,
      0,
      data_topic_id: topic_id,
      class: "badge badge-pill badge-light ml-1 d-none"
    )
  end

  def icon(class), do: content_tag(:i, "", class: class)

  def user?(conn), do: !!Coherence.current_user(conn)
  def admin?(conn), do: user?(conn) && Coherence.current_user(conn).admin

  def nav_text(text, icon \\ false) do
    text = if icon, do: [icon(icon), text], else: text
    text = content_tag(:span, text, class: "navbar-text")
    [content_tag(:li, text, class: "nav-item")]
  end

  @spec nav_item(conn, String.t(), String.t(), Keyword.t()) :: [any] | []
  def nav_item(conn, text, to, opts \\ []) do
    if Keyword.get(opts, :show, true) do
      active = Keyword.get(opts, :active, true)
      topic_id = Keyword.get(opts, :topic_id, false)
      method = Keyword.get(opts, :method, :get)
      icon = Keyword.get(opts, :icon, false)
      popover = Keyword.get(opts, :popover, false)
      tooltip = Keyword.get(opts, :tooltip, false)
      placement = Keyword.get(opts, :placement, "bottom")

      item_class =
        if active and current_path(conn, %{}) === to,
          do: "topic-link nav-item active",
          else: "topic-link nav-item"

      text =
        cond do
          icon && topic_id -> [icon(icon), text, badge(topic_id)]
          icon -> [icon(icon), text]
          topic_id -> [text, badge(topic_id)]
          true -> text
        end

      link =
        cond do
          popover ->
            link(text, to: to, class: "nav-link", data_content: popover)

          tooltip ->
            link(
              text,
              to: to,
              class: "nav-link",
              method: method,
              data_toggle: "tooltip",
              data_placement: placement,
              title: tooltip
            )

          true ->
            link(text, to: to, class: "nav-link", method: method)
        end

      [content_tag(:li, link, class: item_class)]
    else
      []
    end
  end
end
