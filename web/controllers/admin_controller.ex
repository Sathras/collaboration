defmodule Collaboration.AdminController do
  use Collaboration.Web, :controller

  alias Collaboration.Data
  alias Collaboration.Topic
  alias Collaboration.User

  plug :auth_user

  def index(conn, _params) do
    conn
    |> render("index.html")
  end
end