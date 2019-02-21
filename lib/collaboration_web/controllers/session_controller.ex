defmodule CollaborationWeb.SessionController do
  use CollaborationWeb, :controller

  def new(conn, _) do
    render conn, "new.html"
  end

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

  def delete(conn, _) do
    if condition(conn) == 0 do
      conn
      |> CollaborationWeb.Auth.logout()
      |> redirect(to: Routes.session_path(conn, :new))
    else
      user = current_user(conn)
      update_user! user, %{completed_at: NaiveDateTime.utc_now()}

      conn
      |> CollaborationWeb.Auth.logout()
      |> redirect(to: Routes.user_path(conn, :complete, surveycode:
        Application.fetch_env!(:collaboration, :survey_codes)[user.condition]))
    end
  end
end
