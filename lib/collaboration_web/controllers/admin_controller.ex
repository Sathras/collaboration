defmodule CollaborationWeb.AdminController do
  use CollaborationWeb, :controller

  plug(CollaborationWeb.Plug.IsAdmin)
  def users(conn, _params), do: render(conn, "users.html")
end
