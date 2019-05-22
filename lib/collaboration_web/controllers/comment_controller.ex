defmodule CollaborationWeb.CommentController do
  use CollaborationWeb, :controller

  import Collaboration.Contributions

  def toggle_like(conn, %{"id" => comment_id}) do
    toggle_like_comment(comment_id, current_user(conn).id)
    redirect conn, to: Routes.topic_path(conn, :show)
  end
end
