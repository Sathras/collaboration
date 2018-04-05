defmodule CollaborationWeb.ViewHelpers do
  @moduledoc """
  Conveniences that can be used in any views and templates.
  """
  use Phoenix.HTML
  import Phoenix.Controller, only: [current_path: 2]

  @type conn :: Plug.Conn.t

  # displays a FontAwesome 5 icon
  def icon(class), do: content_tag(:i, "", class: class)

  @spec nav_item(conn, String.t, String.t, Keyword.t) :: [any] | []
  def nav_item(conn, text, to, opts \\ []) do
    if Keyword.get(opts, :show, true) do
      active      = Keyword.get(opts, :active, true)
      method      = Keyword.get(opts, :method, :get)
      icon        = Keyword.get(opts, :icon, false)
      tooltip     = Keyword.get(opts, :tooltip, false)
      tooltipPos  = Keyword.get(opts, :tooltipPos, "bottom")

      item_class = if active and current_path(conn, %{}) === to,
        do: "nav-item active", else: "nav-item"
      text = if icon, do: [icon(icon), text], else: text
      link = if tooltip, do: link(text,
        to: to,
        class: "nav-link",
        method: method,
        data_toggle: "tooltip",
        data_placement: tooltipPos,
        title: tooltip
      ),
      else: link(text, to: to, class: "nav-link", method: method)
      [content_tag(:li, link, class: item_class)]
    else
      []
    end
  end

end