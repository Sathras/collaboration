defmodule CollaborationWeb.Plug.IsAdmin do
  import Plug.Conn
  import Phoenix.Controller
  import CollaborationWeb.Gettext

  def init(opts), do: opts

  def call(conn, _opts) do
    if Coherence.current_user(conn).condition == 0 do
      conn
    else
      msg =
        dgettext(
          "coherence",
          "You need to be an administrator to access this page."
        )

      conn
      |> put_status(403)
      |> render(CollaborationWeb.ErrorView, "403.html", msg: msg)
    end
  end
end
