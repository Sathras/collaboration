defmodule CollaborationWeb.UserController do
  use CollaborationWeb, :controller

  import Collaboration.Coherence.Schemas

  def start(conn, _) do
    render conn, "start.html", changeset: change_user(:experiment, %{})
  end

  def complete(conn, _), do: render conn, "complete.html"

  def create(conn, %{"user" => params }) do
    case create_user_for_experiment(params) do
      {:ok, user} ->
        {:ok, user} = Coherence.ConfirmableService.confirm!(user)
        params = %{
          "remember" => false,
          "session" => %{"email" => user.email, "password" => "password"}
        }
        Coherence.SessionController.create(conn, params)

      {:error, changeset} ->
        conn
        |> put_flash(:error, "Your passcode seems to be invalid.")
        |> render("start.html", changeset: changeset)
    end
  end

  def index(conn, _), do: render conn, "index.html", users: list_users()

  # toggle admin flag
  def update(conn, %{"id" => id}) do
    user = get_user!(id)
    case update_user(user, %{ admin: !user.admin }) do
      {:ok, _user} ->
        conn
        |> put_flash(:info, "User updated successfully.")
        |> redirect(to: user_path(conn, :index))

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
    |> redirect(to: user_path(conn, :complete, surveycode: surveycode))
  end
end
