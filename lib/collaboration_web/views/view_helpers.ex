defmodule CollaborationWeb.ViewHelpers do
  @moduledoc """
  Conveniences that can be used in any views and templates.
  """
  use Phoenix.HTML
  import Phoenix.Controller, only: [current_path: 2]

  @type conn :: Plug.Conn.t()

  def date(datetime), do: datetime && NaiveDateTime.to_iso8601(datetime) <> "Z"
  def icon(class), do: content_tag(:i, "", class: class)

  def current_user(conn), do: conn.assigns.current_user
  def participant?(conn), do: condition(conn) > 0
  def admin?(conn), do: condition(conn) == 0

  # get details of current user (no check)
  def condition(conn), do: current_user(conn) && current_user(conn).condition
  def user_id(conn), do: current_user(conn) && current_user(conn).id

  def nav_text(text, icon \\ false) do
    text = if icon, do: [icon(icon), text], else: text
    text = content_tag(:span, text, class: "navbar-text")
    [content_tag(:li, text, class: "nav-item")]
  end

  def nav_item(conn, text, to) do
    active = if current_path(conn, %{}) === to, do: " active", else: ""
    content_tag(:li, link(text, to: to, class: "nav-link"),
      class: "nav-item #{active}")
  end
end
