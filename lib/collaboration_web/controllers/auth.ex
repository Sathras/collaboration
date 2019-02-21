defmodule CollaborationWeb.Auth do

  use CollaborationWeb, :controller

  def init(opts), do: opts

  def call(conn, _opts) do
    user_id = get_session(conn, :user_id)
    user = user_id && get_user(user_id)
    assign(conn, :current_user, user)
  end

  def login(conn, user) do
    conn
    |> assign(:current_user, user)
    |> put_session(:user_id, user.id)
    |> configure_session(renew: true)
  end

  def logout(conn) do
    configure_session(conn, drop: true)
  end

  def login_by_username_and_pass(conn, username, given_pass) do
    case authenticate_by_username_and_pass(username, given_pass) do
      {:ok, user} -> {:ok, login(conn, user)}
      {:error, :unauthorized} -> {:error, :unauthorized, conn}
      {:error, :not_found} -> {:error, :not_found, conn}
    end
  end

  def authenticate_user(conn, _opts) do
    if current_user(conn) do
      conn
    else
      conn
      |> put_flash(:error, "You must be logged in to access that page")
      |> redirect(to: Routes.user_path(conn, :new))
      |> halt()
    end
  end

  def authenticate_admin(conn, _opts) do
    if condition(conn) == 0 do
      conn
    else
      conn
      |> put_flash(:error, "You must be an administrator to access that page")
      |> redirect(to: Routes.topic_path(conn, :show))
      |> halt()
    end
  end
end
