defmodule CollaborationWeb.UserController do
  use CollaborationWeb, :controller

  alias Collaboration.Accounts
  alias Collaboration.Accounts.User

  @doc """
  Allows to start an experiment by providing a form to create a participant.
  Serves as the landing page for unauthenticated users.
  """
  def new(conn, _params) do
    render conn, "new.html", changeset: Accounts.change_user(%User{})
  end

  @doc """
  Create a participant user. On success start experiment by showing topic.
  """
  def create(conn, %{"user" => user_params }) do
    case Accounts.create_user(user_params) do
      {:ok, user} ->
        conn
        |> CollaborationWeb.Auth.login(user)
        |> redirect(to: Routes.topic_path(conn, :show))

      {:error, %Ecto.Changeset{} = changeset} ->
        render conn, "new.html", changeset: changeset
    end
  end

  @doc """
  Shows a list of bot and admin users.
  """
  def index(conn, _) do
    render conn, "index.html", users: Accounts.list_users()
  end

  @doc """
  Shows a list of participant users.
  """
  def participants(conn, _) do
    render conn, "participants.html", users: Accounts.list_participants()
  end
end
