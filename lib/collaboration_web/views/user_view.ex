defmodule CollaborationWeb.UserView do
  use CollaborationWeb, :view

  def participants_link(conn) do
    link "Participants",
      to: Routes.user_path(conn, :participants),
      class: "btn btn-primary"
  end

  def users_link(conn) do
    link "Users",
      to: Routes.user_path(conn, :index),
      class: "btn btn-primary"
  end

  # for admin:users list
  def render("user.json", %{user: u}) do
    %{
      id: u.id,
      name: u.name,
      email: u.email,
      condition: u.condition,
      created: date(u.inserted_at)
    }
  end
end
