defmodule CollaborationWeb.UserView do
  use CollaborationWeb, :view

  def toggle_class(user, flag) do
    cond do
      flag === :admin && user.admin -> "text-primary fas fa-user-plus"
      flag === :owner && user.owner -> "text-success fas fa-user-plus"
      true -> "text-muted fas fa-user"
    end
  end

  def toggle_title(user, flag) do
    cond do
      flag === :admin && user.admin -> "Admin"
      flag === :owner && user.owner -> "Owner"
      true -> "Normal User"
    end
  end

  def toggle_icon(user, flag) do
    content_tag :i, "",
      class: toggle_class(user, flag),
      data_id: user.id,
      data_param: Atom.to_string(flag),
      data_value: Map.get(user, flag),
      drab_click: "toggle",
      data_toggle: "tooltip",
      title: toggle_title(user, flag)
  end

  # for admin:users list
  def render("user.json", %{user: u}) do
    %{
      id: u.id,
      name: u.name,
      email: u.email,
      admin: u.admin,
      owner: u.owner,
      condition: u.condition,
      created: NaiveDateTime.to_iso8601(u.inserted_at) <> "Z"
    }
  end
end
