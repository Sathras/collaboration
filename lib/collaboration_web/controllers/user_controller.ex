defmodule CollaborationWeb.UserController do
  use CollaborationWeb, :controller

  import Collaboration.Coherence.Schemas

  plug CollaborationWeb.Plug.IsAdmin

  def index(conn, params) do
    page = list_users(params)
    render conn, "index.html",
      condition: "0",
      search: Map.get(params, "search", ""),
      page_number: page.page_number,
      page_size: page.page_size,
      total_pages: page.total_pages,
      total_entries: page.total_entries,
      users: page.entries
  end

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
end
