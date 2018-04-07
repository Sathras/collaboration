defmodule CollaborationWeb.LayoutView do
  use CollaborationWeb, :view

  @doc """
  Generates name for the JavaScript view we want to use
  in this combination of view/template.
  """
  def js_view_name(conn, view_template) do
    [view_name(conn), template_name(view_template)]
    |> Enum.reverse
    |> List.insert_at(0, "view")
    |> Enum.map(&String.capitalize/1)
    |> Enum.reverse
    |> Enum.join("")
  end

  # Takes the resource name of the view module and removes the
  # the ending *_view* string.
  defp view_name(conn) do
    conn
    |> view_module
    |> Phoenix.Naming.resource_name
    |> String.replace("_view", "")
  end

  # Removes the extion from the template and reutrns
  # just the name.
  defp template_name(template) when is_binary(template) do
    template
    |> String.split(".")
    |> Enum.at(0)
  end

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
