defmodule Collaboration.PageController do
  use Collaboration.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
