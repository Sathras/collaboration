defmodule CollaborationWeb.UserView do
  use CollaborationWeb, :view

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
