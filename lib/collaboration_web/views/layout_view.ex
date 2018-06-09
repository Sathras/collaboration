defmodule CollaborationWeb.LayoutView do
  use CollaborationWeb, :view

  @doc """
  Generates name for the JavaScript view we want to use
  in this combination of view/template.
  """
  def js_view_name(conn, view_template) do
    [view_name(conn), template_name(view_template)]
    |> Enum.reverse()
    |> List.insert_at(0, "view")
    |> Enum.map(&String.capitalize/1)
    |> Enum.reverse()
    |> Enum.join("")
  end

  def path_params_to_data_attributes(conn),
    do:
      Enum.map(conn.path_params, fn {p, v} -> " data-#{p}=#{v}" end)
      |> Enum.join()

  # Takes the resource name of the view module and removes the
  # the ending *_view* string.
  defp view_name(conn) do
    conn
    |> view_module
    |> Phoenix.Naming.resource_name()
    |> String.replace("_view", "")
  end

  # Removes the extion from the template and reutrns
  # just the name.
  defp template_name(template) when is_binary(template) do
    template
    |> String.split(".")
    |> Enum.at(0)
  end

  # FLASH MESSAGES
  def flash_color(type) do
    case type do
      :info -> "info"
      _ -> "danger"
    end
  end

  def flash_icon(type) do
    case type do
      :info -> "fa-info-circle"
      _ -> "fa-exclamation-circle"
    end
  end

  def flash_messages(conn) do
    [
      flash_alert(get_flash(conn, :info), "info", "fas fa-info-circle"),
      flash_alert(
        get_flash(conn, :error),
        "danger",
        "fas fa-exclamation-circle"
      )
    ]
    |> Enum.filter(& &1)
  end

  defp flash_alert(message, class, icon) do
    icon = content_tag(:i, "", class: icon <> " mr-2")

    button =
      content_tag(
        :button,
        content_tag(:span, raw("&times;"), area_hidden: "true"),
        class: "close",
        type: "button",
        data_dismiss: "alert",
        aria_label: "Close"
      )

    if message do
      content_tag(
        :div,
        [icon, message, button],
        class: "alert alert-#{class} alert-dismissible fade show"
      )
    end
  end

  def ga_code() do
    if Application.get_env(:collaboration, :env) == :dev,
      do: "UA-119119225-1",
      else: "UA-119138942-1"
  end

  def remaining_seconds(user) do
    started = user.confirmed_at
    now = NaiveDateTime.utc_now()
    NaiveDateTime.diff(started, now) + 60 * 10
  end

  def timer_button(conn) do
    user = current_user(conn)
    started = user.confirmed_at
    now = NaiveDateTime.utc_now()
    countdown = NaiveDateTime.diff(started, now) + 60 * 1 # 10 minutes from start
    if countdown <= 0 do
      button "Complete Experiment",
        id: "timer",
        class: "btn btn-success",
        data_confirm: "Are you sure? This will move you to the survey!",
        to: user_path(conn, :finish)
    else
      minutes = Integer.floor_div(countdown, 60)
      seconds = Integer.mod(countdown, 60)
      button "#{minutes}:#{seconds} remaining",
        id: "timer",
        class: "btn btn-light",
        data_confirm: "Are you sure? This will move you to the survey!",
        data_remaining: countdown,
        disabled: true,
        to: user_path(conn, :finish)
    end
  end
end
