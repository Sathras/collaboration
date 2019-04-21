defmodule CollaborationWeb.SessionController do
  use CollaborationWeb, :controller

  def aborted(conn, _), do: render conn, "aborted.html"
  def complete(conn, _), do: render conn, "complete.html"

  def create(conn, %{"session" => %{"username" => username, "password" => pass}}) do
    case CollaborationWeb.Auth.login_by_username_and_pass(conn, username, pass) do
      {:ok, conn} ->
        redirect conn, to: Routes.topic_path(conn, :show)

      {:error, _reason, conn} ->
        conn
        |> put_flash(:error, "Invalid email/password combination")
        |> render("new.html")
    end
  end

  def delete(conn, %{ "completed" => test }) do
    IO.inspect test

    current_user(conn)
    |> complete_user(true)

    conn
    |> CollaborationWeb.Auth.logout()
    |> redirect(to: Routes.session_path(conn, :complete))
  end

  def delete(conn, %{ "aborted" => test }) do
    IO.inspect test

    current_user(conn)
    |> complete_user(false)

    conn
    |> CollaborationWeb.Auth.logout()
    |> redirect(to: Routes.session_path(conn, :aborted))
  end

  def delete(conn, _) do
    conn
    |> CollaborationWeb.Auth.logout()
    |> redirect(to: Routes.session_path(conn, :new))
  end

  def new(conn, _) do
    render conn, "new.html"
  end
end
