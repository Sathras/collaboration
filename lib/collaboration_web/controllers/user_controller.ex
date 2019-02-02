defmodule CollaborationWeb.UserController do
  use CollaborationWeb, :controller

  import Collaboration.Coherence.Schemas

  def complete(conn, _), do: render conn, "complete.html"

  def create(conn, %{"user" => user_params }) do
    case create_participant(user_params) do
      {:ok, user} ->

        # TODO: Start worker that autonomiously adds ideas and comments

        params = %{
          "remember" => false,
          "session" => %{
            "email" => user.email,
            "password" => Application.fetch_env!(:collaboration, :password)
          }
        }
        Coherence.SessionController.create(conn, params)

      {:error, changeset} ->
        render conn, "new.html", changeset: changeset
    end
  end

  def new(conn, _params) do
    if current_user(conn) do
      redirect(conn, to: Routes.topic_path(conn, :show))
    else
      render conn, "new.html", changeset: change_participant()
    end
  end

  def index(conn, _) do
    render conn, "index.html", users: list_users()
  end

  def participants(conn, _) do
    render conn, "participants.html", users: list_participants()
  end

  # finish experiment gracefully
  def finish(conn, _) do
    user = current_user(conn)
    update_user(user, %{completed: true})

    conn
    |> Coherence.Controller.logout_user
    |> redirect(to: Routes.user_path(conn, :complete,
      surveycode: Application.fetch_env!(:collaboration, :survey_codes)[user.condition]
    ))
  end
end
