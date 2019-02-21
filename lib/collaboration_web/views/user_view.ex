defmodule CollaborationWeb.UserView do
  use CollaborationWeb, :view

  def render("user.json", %{user: u}) do
    %{
      id: u.id,
      name: u.name,
      condition: u.condition,
      inserted_at: date(u.inserted_at),
      completed_at: date(u.completed_at)
    }
  end
end
