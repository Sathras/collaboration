defmodule CollaborationWeb.UserController do
  use CollaborationWeb, :controller

  import Collaboration.Coherence.Schemas

  def complete(conn, _), do: render conn, "complete.html"

  def create(conn, %{"user" => user_params }) do
    case create_participant(user_params) do
      {:ok, user} ->
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
    render conn, "new.html", changeset: change_participant()
  end

  def index(conn, _) do
    render conn, "index.html", users: list_users()
  end

  def participants(conn, _) do
    render conn, "participants.html", users: list_participants()
  end

  # toggle admin flag
  def update(conn, %{"id" => id}) do
    user = get_user!(id)
    case update_user(user, %{ admin: !user.admin }) do
      {:ok, _user} ->
        conn
        |> put_flash(:info, "User updated successfully.")
        |> redirect(to: Routes.user_path(conn, :index))

      {:error, changeset} ->
        render(conn, "edit.html", changeset: changeset)
    end
  end

  # finish experiment gracefully
  def finish(conn, _) do
    user = current_user(conn)
    update_user(user, %{completed: true})
    surveycode = case user.condition do
      1 -> "condition 1 code"
      2 -> "condition 2 code"
      3 -> "condition 3 code"
      4 -> "condition 4 code"
    end
    conn
    |> Coherence.Controller.logout_user
    |> redirect(to: Routes.user_path(conn, :complete, surveycode: surveycode))
  end
end
