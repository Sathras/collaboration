defmodule Collaboration.AdminController do
  use Collaboration.Web, :controller

  alias Collaboration.Data
  alias Collaboration.User

  # Admin Interface for User Management, User groups, ...
  def index(conn, _params) do

    instructions = Repo.get!(Data, 1) #id 1 = instructions
    changeset = Data.changeset(instructions)

    users = Repo.all(User)

    conn
    |> render("index.html", users: users, instructions_changeset: changeset)
  end

  def update(conn, %{"id" => id, "data" => data_params}) do

    instructions = Repo.get!(Data, id)
    changeset = Data.changeset(instructions, data_params)

    case Repo.update(changeset) do
      {:ok, data} ->
        conn
        |> put_flash(:info, "Data updated successfully.")
        |> redirect(to: admin_path(conn, :index))
      {:error, changeset} ->
        users = Repo.all(User)
        render(conn, "index.html", users: users, instructions_changeset: changeset)
    end
  end
end