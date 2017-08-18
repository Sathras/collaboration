defmodule Collaboration.AdminController do
  use Collaboration.Web, :controller

  # plug :authenticate when action in [:delete, :edit]

  alias Collaboration.User

  # Admin Interface for User Management, User groups, ...
  def index(conn, _params) do
    users = Repo.all(User)
    render(conn, "index.html", users: users)
  end
end