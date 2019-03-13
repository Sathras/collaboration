defmodule CollaborationWeb.SessionController do
  use CollaborationWeb, :controller

  @survey_codes Application.fetch_env!(:collaboration, :survey_codes)

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

  def delete(conn, %{ "completed" => _ }) do
    user = current_user(conn)
    update_user! user, %{ completed_at: NaiveDateTime.utc_now() }
    code = @survey_codes[user.condition]

    conn
    |> CollaborationWeb.Auth.logout()
    |> redirect(to: Routes.session_path(conn, :complete, surveycode: code))
  end

  def delete(conn, %{ "aborted" => _ }) do
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
