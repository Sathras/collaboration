defmodule CollaborationWeb.PageController do
  use CollaborationWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
