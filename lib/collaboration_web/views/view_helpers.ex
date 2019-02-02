defmodule CollaborationWeb.ViewHelpers do
  @moduledoc """
  Conveniences that can be used in any views and templates.
  """
  use Phoenix.HTML
  import Phoenix.Controller, only: [current_path: 2]
  import Coherence, only: [current_user: 1]

  @type conn :: Plug.Conn.t()

  def authenticated?(conn), do: !!current_user(conn)
  def condition(conn), do: current_user(conn) && current_user(conn).condition
  def date(datetime), do: NaiveDateTime.to_iso8601(datetime) <> "Z"
  def icon(class), do: content_tag(:i, "", class: class)
  def participant?(conn),
    do: current_user(conn) && current_user(conn).condition > 0
  def admin?(conn), do: current_user(conn) && current_user(conn).condition == 0
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
