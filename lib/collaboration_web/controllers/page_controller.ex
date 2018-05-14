defmodule CollaborationWeb.PageController do
  use CollaborationWeb, :controller

  def index(conn, _), do: redirect(conn, to: topic_path(conn, :index))
end
