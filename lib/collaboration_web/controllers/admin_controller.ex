defmodule CollaborationWeb.AdminController do
  use CollaborationWeb, :controller

  plug CollaborationWeb.Plug.IsAdmin

  alias Collaboration.Coherence.Schemas

  def users(conn, _params) do
    render(conn, "users.html")
  end

  def toggle_admin(conn, %{"id" => id}) do
    user = Schemas.get_user!(id)
    case Schemas.toggle(user, %{"admin": !user.admin}) do
      {:ok, _user} ->
        conn
        |> put_flash(:info, "User updated successfully.")
        |> redirect(to: admin_path(conn, :users))
      {:error, _changeset} ->
        conn
        |> put_flash(:info, "Error updateing users.")
        |> redirect(to: admin_path(conn, :users))
    end
  end

  def toggle_feedback(conn, %{"id" => id}) do
    user = Schemas.get_user!(id)
    case Schemas.toggle(user, %{"feedback": !user.feedback}) do
      {:ok, user} ->
      IO.inspect user
        conn
        |> put_flash(:info, "User updated successfully.")
        |> redirect(to: admin_path(conn, :users))
      {:error, _changeset} ->
        conn
        |> put_flash(:info, "Error updating users.")
        |> redirect(to: admin_path(conn, :users))
    end
  end
end
