defmodule CollaborationWeb.CommentController do
  use CollaborationWeb, :controller

  def create(conn, %{"comment" => params}) do
    params = Map.put params, "user_id", conn.assigns.current_user.id
    case create_comment(params) do
      {:ok, _comment} ->
        conn
        |> redirect(to: Routes.topic_path(conn, :show))

      {:error, changeset} ->
        conn
        |> put_flash(:error, "Comment could not be created.")
        |> redirect(to: Routes.topic_path(conn, :show))
    end
  end
end
