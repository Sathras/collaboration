defmodule CollaborationWeb.UserView do
  use CollaborationWeb, :view

  # for admin:users list
  def render("user.json", %{user: u}) do
    %{
      id: u.id,
      row_id: "user_#{u.id}",
      name: u.name,
      email: u.email,
      admin: u.admin,
      feedback: u.feedback,
      created: NaiveDateTime.to_iso8601(u.inserted_at)<>"Z",
    }
  end
end