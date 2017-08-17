defmodule Collaboration.LayoutView do
  use Collaboration.Web, :view

  def nav_class(conn, route) do
    if conn.request_path == route, do: "nav-item active", else: "nav-item"
  end
end
