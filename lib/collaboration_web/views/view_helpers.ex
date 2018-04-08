defmodule CollaborationWeb.ViewHelpers do
  @moduledoc """
  Conveniences that can be used in any views and templates.
  """
  use Phoenix.HTML
  import Phoenix.Controller, only: [current_path: 2]

  @type conn :: Plug.Conn.t

  def badge(text), do: content_tag(:span, text, class: "badge badge-pill badge-light ml-1")
  def icon(class), do: content_tag(:i, "", class: class)

  def user?(conn), do: !!Coherence.current_user(conn)
  def admin?(conn), do: Coherence.current_user(conn) && Coherence.current_user(conn).admin

  def nav_text(text, icon \\ false) do
    text = if icon, do: [icon(icon), text], else: text
    text = content_tag(:span, text, class: "navbar-text")
    [content_tag(:li, text, class: "nav-item")]
  end

  @spec nav_item(conn, String.t, String.t, Keyword.t) :: [any] | []
  def nav_item(conn, text, to, opts \\ []) do
    if Keyword.get(opts, :show, true) do
      active    = Keyword.get(opts, :active, true)
      badge     = Keyword.get(opts, :badge, nil)
      method    = Keyword.get(opts, :method, :get)
      icon      = Keyword.get(opts, :icon, false)
      popover   = Keyword.get(opts, :popover, false)
      tooltip   = Keyword.get(opts, :tooltip, false)
      placement = Keyword.get(opts, :placement, "bottom")

      item_class = if active and current_path(conn, %{}) === to,
        do: "nav-item active", else: "nav-item"

      text = cond do
        icon && badge -> [icon(icon), text, badge(badge)]
        icon -> [icon(icon), text]
        badge -> [text, badge(badge)]
        true -> text
      end

      link = cond do
        popover ->
          link(text, to: to,
            class: "nav-link",
            method: method,
            data_container: "body",
            data_content: popover,
            data_html: "true",
            data_toggle: "popover",
            data_trigger: "hover",
            data_placement: placement
          )
        tooltip ->
          link(text,
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