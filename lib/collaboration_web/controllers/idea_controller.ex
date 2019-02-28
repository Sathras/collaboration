defmodule CollaborationWeb.IdeaController do
  use CollaborationWeb, :controller

  def rate(conn, %{"idea_id" => idea_id, "rating" => rating }) do
    rate_idea! rating, idea_id, conn.assigns.current_user.id
    redirect conn, to: Routes.topic_path(conn, :show)
  end

  def unrate(conn, %{"idea_id" => idea_id }) do
    unrate_idea! idea_id, conn.assigns.current_user.id
    redirect conn, to: Routes.topic_path(conn, :show)
  end
end
