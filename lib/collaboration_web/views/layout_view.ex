defmodule CollaborationWeb.LayoutView do
  use CollaborationWeb, :view

  def flash_messages(conn) do
    [
      flash_alert(get_flash(conn, :info), "info", "fas fa-info-circle"),
      flash_alert(get_flash(conn, :error), "danger", "fas fa-exclamation-circle")
    ] |> Enum.filter(& &1)
  end

  defp flash_alert(message, class, icon) do
    icon = content_tag :i, "", class: icon <> " mr-2"
    button = content_tag(:button,
      content_tag(:span, raw("&times;"), area_hidden: "true"),
      class: "close", type: "button", data_dismiss: "alert", aria_label: "Close"
    )
    if message do
      content_tag :div,
        [icon, message, button],
        class: "alert alert-#{class} alert-dismissible fade show"
    end
  end
end
