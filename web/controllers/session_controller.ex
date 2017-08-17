defmodule Collaboration.SessionController do
  use Collaboration.Web, :controller
  alias Collaboration.Auth

  def new(conn, _) do
    if conn.assigns.current_user, do:
      conn
      |> Auth.logout()
      |> redirect(to: "/login"),
    else:
      render conn, "new.html"
  end

  def new(conn, _) do
    conn
    |> put_flash(:error, "Something went wrong with your input")
    |> render("new.html")
  end

  def create(conn, %{"session" => %{"email" => e, "password" => p}}) do
    case Collaboration.Auth.login_by_email_and_pass(conn, e, p, repo: Repo) do
    {:ok, conn} ->
      conn
      |> put_flash(:info, "Welcome back!")
      |> redirect(to: page_path(conn, :index))
    {:error, _reason, conn} ->
      conn
      |> put_flash(:error, "Invalid username/password combination")
      |> render("new.html")
    end
  end

  def delete(conn, _) do
    conn
    |> Auth.logout()
    |> redirect(to: "/")
  end
end