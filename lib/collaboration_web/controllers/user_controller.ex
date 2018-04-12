defmodule CollaborationWeb.UserController do
  use CollaborationWeb, :controller

  plug CollaborationWeb.Plug.IsAdmin

  alias Collaboration.Coherence.Schemas

  def index(conn, _params) do
    users = Schemas.list_user()
    render(conn, "index.html", users: users)
  end

  def toggle_admin(conn, %{"id" => id}) do
    user = Schemas.get_user!(id)
    case Schemas.toggle(user, %{"admin": !user.admin}) do
      {:ok, _user} ->
        conn
        |> put_flash(:info, "User updated successfully.")
        |> redirect(to: user_path(conn, :index))
      {:error, _changeset} ->
        conn
        |> put_flash(:info, "Error updateing users.")
        |> redirect(to: user_path(conn, :index))
    end
  end

  def toggle_feedback(conn, %{"id" => id}) do
    user = Schemas.get_user!(id)
    case Schemas.toggle(user, %{"feedback": !user.feedback}) do
      {:ok, user} ->
      IO.inspect user
        conn
        |> put_flash(:info, "User updated successfully.")
        |> redirect(to: user_path(conn, :index))
      {:error, _changeset} ->
        conn
        |> put_flash(:info, "Error updating users.")
        |> redirect(to: user_path(conn, :index))
    end
  end
end
