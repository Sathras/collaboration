defmodule CollaborationWeb.UserView do
  use CollaborationWeb, :view

  def admin_icon(user) do
    title = if user.admin, do: "Admin", else: "Normal User"
    icon = if user.admin, do: "text-primary fas fa-user-plus", else: "text-muted fas fa-user"
    content_tag :i, "",
      class: "toggle-admin fas #{icon}",
      data_id: "#{user.id}",
      drab_click: "toggle_admin",
      title: title
  end

  # for admin:users list
  def render("user.json", %{user: u}) do
    %{
      id: u.id,
      row_id: "user_#{u.id}",
      name: u.name,
      email: u.email,
      admin: u.admin,
      condition: u.condition,
      created: NaiveDateTime.to_iso8601(u.inserted_at) <> "Z"
    }
  end
end
