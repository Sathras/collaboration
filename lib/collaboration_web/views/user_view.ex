defmodule CollaborationWeb.UserView do
  use CollaborationWeb, :view

  def duration(user) do
    if is_nil(user.updated_at) do
      "not completed"
    else
      NaiveDateTime.diff(user.updated_at, user.inserted_at)
    end
  end

  def render("user.json", %{user: u}) do
    %{
      id: u.id,
      name: u.name,
      condition: u.condition,
      inserted_at: date(u.inserted_at),
      completed_at: date(u.updated_at)
    }
  end
end
