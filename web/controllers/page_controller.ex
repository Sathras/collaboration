defmodule Collaboration.PageController do
  use Collaboration.Web, :controller

  def index(conn, _params) do
    redirect conn, to: topic_path(conn, :index)
  end
end
