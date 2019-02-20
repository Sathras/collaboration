defmodule CollaborationWeb.CommentController do
  use CollaborationWeb, :controller

  def create(conn, %{"comment" => params}) do
    params = Map.put params, "user_id", conn.assigns.current_user.id
    case create_comment(params) do
      {:ok, _comment} ->
        conn
        |> redirect(to: Routes.topic_path(conn, :show))

      {:error, _changeset} ->
        conn
        |> put_flash(:error, "Comment could not be created.")
        |> redirect(to: Routes.topic_path(conn, :show))
    end
  end

  def like(conn, %{"comment_id" => comment_id }) do
    like_comment conn.assigns.current_user, comment_id
    redirect conn, to: Routes.topic_path(conn, :show)
  end

  def unlike(conn, %{"comment_id" => comment_id }) do
    unlike_comment conn.assigns.current_user, comment_id
    redirect conn, to: Routes.topic_path(conn, :show)
  end
end
