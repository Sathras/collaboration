defmodule CollaborationWeb.UserView do
  use CollaborationWeb, :view

  def user_icon(admin) do
    color = if admin, do: "text-primary", else: "text-muted"
    icon = if admin, do: "fa-user-plus", else: "fa-user"
    content_tag :i, "", class: "fas #{icon} #{color}"
  end

  def toggle_admin(conn, user) do
    current_user = Coherence.current_user(conn)
    color = if user.admin, do: "danger", else: "success"
    label = if user.admin, do: "Demote", else: "Promote"
    if(user.id === current_user.id) do
      content_tag :button, label, class: "btn btn-sm btn-light disabled",
      data_toggle: "tooltip", title: "You cannot demote yourself!"
    else
      action = user_path(conn, :toggle_admin, user.id)
      button label, to: action, method: "put", class: "btn btn-sm btn-#{color}"
    end
  end

  def toggle_feedback(conn, user) do
    current_user = Coherence.current_user(conn)
    color = if user.feedback, do: "danger", else: "success"
    label = if user.feedback, do: "No Feedback", else: "Feedback"
    action = user_path(conn, :toggle_feedback, user.id)
    button label, to: action, method: "put", class: "btn btn-sm btn-#{color}"
  end
end