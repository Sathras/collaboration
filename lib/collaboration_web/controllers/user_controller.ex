defmodule CollaborationWeb.UserController do
  use CollaborationWeb, :controller

  alias Collaboration.Accounts.User

  # start page to create experiment users
  def new(conn, _params) do
    render conn, "new.html", changeset: User.changeset(%User{})
  end

  def create(conn, %{"user" => user_params }) do
    case create_user(user_params) do
      {:ok, user} ->
        conn
        |> CollaborationWeb.Auth.login(user)
        |> redirect(to: Routes.topic_path(conn, :show))

      {:error, changeset} ->
        render conn, "new.html", changeset: changeset
    end
  end

  def index(conn, _) do
    render conn, "index.html", users: list_users()
  end

  def participants(conn, _) do
    render conn, "participants.html", users: list_participants()
  end
end
