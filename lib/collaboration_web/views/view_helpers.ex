defmodule CollaborationWeb.ViewHelpers do
  @moduledoc """
  Conveniences that can be used in any views and templates.
  """
  use Phoenix.HTML

  @type conn :: Plug.Conn.t()

  @doc """
    Converts a NaiveDateTime to a iso8601 formated string.
  """
  def date(datetime), do: datetime && NaiveDateTime.to_iso8601(datetime) <> "Z"

  def current_user(conn), do: conn.assigns.current_user
  def admin?(conn), do: user_cond(conn) == 0

  # get details of current user (no check)
  def user_cond(conn), do: current_user(conn) && current_user(conn).condition
end
