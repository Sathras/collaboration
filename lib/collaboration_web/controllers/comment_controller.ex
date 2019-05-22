defmodule CollaborationWeb.CommentController do
  use CollaborationWeb, :controller

  import Collaboration.Contributions

  def create(conn, %{"comment" => comment_params}) do
    create_comment(comment_params, current_user(conn))
    redirect conn, to: Routes.topic_path(conn, :show)
  end

  def toggle_like(conn, %{"id" => comment_id}) do
    toggle_like_comment(comment_id, current_user(conn).id)
    redirect conn, to: Routes.topic_path(conn, :show)
  end
end
