defmodule CollaborationWeb.CommentController do
  use CollaborationWeb, :controller

  import Collaboration.Contributions

  def index(conn, _params) do
    redirect conn, to: Routes.topic_path(conn, :show)
  end

  def create(conn, %{"comment" => comment_params}) do
    case create_comment(current_user(conn), comment_params) do
      {:ok, _comment} ->
        redirect conn, to: Routes.topic_path(conn, :show)

      {:error, changeset} ->
        conn
        |> CollaborationWeb.TopicController.prepare_topic()
        |> assign(:comment_changeset, changeset)
        |> put_view(CollaborationWeb.TopicView)
        |> render("show.html")
    end
  end

  def toggle_like(conn, %{"id" => comment_id}) do
    toggle_like_comment(comment_id, current_user(conn).id)
    redirect conn, to: Routes.topic_path(conn, :show)
  end
end
