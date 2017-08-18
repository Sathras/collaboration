defmodule Collaboration.UserController do
  use Collaboration.Web, :controller

  plug :auth_user when action in [:delete, :edit, :update]

  alias Collaboration.User

  def index(conn, _params) do
    users = Repo.all(User)
    render(conn, "index.html", users: users)
  end

  def new(conn, params) do
    changeset = User.changeset_login(%User{}, params)
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"user" => user_params}) do
    changeset = User.changeset_register(%User{}, user_params)

    case Repo.insert(changeset) do
      {:ok, user} ->
        conn
        |> Collaboration.Auth.login(user)
        |> put_flash(:info, "Welcome to the community, #{user.firstname}")
        |> redirect(to: "/")
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    user = Repo.get!(User, id)
    render(conn, "show.html", user: user)
  end

  def edit(conn, params) do

    self = if params["id"], do: false, else: true
    user = Repo.get!(User, params["id"] || conn.assigns.current_user.id)

    changeset = User.changeset_update(user, params, self)

    conn
    |> assign(:self, self)
    |> assign(:user_id, params["id"] || conn.assigns.current_user.id)
    |> render("edit.html", user: user, changeset: changeset)
  end

  def update(conn, %{"id" => id, "user" => user_params}) do

    self = if user_params["self"], do: true, else: false
    curr_pass = if self, do: conn.assigns.current_user.password_hash, else: false

    user = Repo.get!(User, id)
    changeset = User.changeset_update(user, user_params, curr_pass)

    case Repo.update(changeset) do

      {:ok, user} ->
        conn = put_flash(conn, :info, "User updated successfully.")
        if self, do: redirect(conn, to: user_path(conn, :show, user)),
        else: redirect(conn, to: "/admin")

      {:error, changeset} ->
        conn
        |> assign(:self, self)
        |> assign(:user_id, id)
        |> render("edit.html", user: user, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    user = Repo.get!(User, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(user)

    conn
    |> put_flash(:info, "User deleted successfully.")
    |> redirect(to: user_path(conn, :index))
  end
end
