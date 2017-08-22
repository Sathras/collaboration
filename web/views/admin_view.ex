defmodule Collaboration.AdminView do
  use Collaboration.Web, :view

  def navtab_class(conn, action) do
    if action_name(conn) == action, do: "nav-link active", else: "nav-link"
  end
end
