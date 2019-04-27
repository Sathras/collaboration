defmodule CollaborationWeb.SessionController do
  use CollaborationWeb, :controller

  alias CollaborationWeb.Auth

  def abort(conn, _), do: render conn, "abort.html"
  def complete(conn, _), do: render conn, "complete.html"

  def create(conn, %{"session" => %{"username" => u, "password" => p}}) do
    case Auth.login_by_username_and_pass(conn, u, p) do
      {:ok, conn} ->
        redirect conn, to: Routes.topic_path(conn, :show)

      {:error, _reason, conn} ->
        conn
        |> put_flash(:error, "Invalid email/password combination")
        |> render("new.html")
    end
  end

  @doc """
  Logout user that completed the experiment and update their completion status.
  """
  def delete(conn, %{ "completed" => "true"}) do
    conn
    |> Auth.logout(true)
    |> redirect(to: Routes.session_path(conn, :complete))
  end

  @doc """
  Logout users that aborted the experiment and update their completion status.
  """
  def delete(conn, %{ "completed" => "false"}) do
    conn
    |> Auth.logout(false)
    |> redirect(to: Routes.session_path(conn, :abort))
  end

  @doc """
  Logout admin and redirect to (admin) login page.
  """
  def delete(conn, _) do
    conn
    |> Auth.logout()
    |> redirect(to: Routes.session_path(conn, :new))
  end

  def new(conn, _), do: render conn, "new.html"
end
