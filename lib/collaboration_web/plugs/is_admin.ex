defmodule CollaborationWeb.Plug.IsAdmin do
  import Plug.Conn
  import Phoenix.Controller

  import CollaborationWeb.ViewHelpers, only: [admin?: 1]

  def init(opts), do: opts

  def call(conn, _opts) do
    if admin?(conn) do
      conn
    else
      conn
      |> put_status(403)
      |> render(CollaborationWeb.ErrorView, "403.html",
          msg: "You need to be an administrator to access this page.")
    end
  end
end
