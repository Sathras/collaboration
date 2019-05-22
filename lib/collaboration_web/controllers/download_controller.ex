defmodule CollaborationWeb.DownloadController do
  use CollaborationWeb, :controller

  def index(conn, _) do
    render conn, "index.html"
  end
end
