defmodule CollaborationWeb.LayoutView do
  use CollaborationWeb, :view

  import Collaboration.Contributions
  alias CollaborationWeb.UserView

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
      do: Application.fetch_env!(:collaboration, :ga_dev_code),
      else: Application.fetch_env!(:collaboration, :ga_prod_code)
  end

  def remaining_seconds(user) do
    started = user.confirmed_at
    now = NaiveDateTime.utc_now()
    NaiveDateTime.diff(started, now) + 60 * 10
  end

  def time_passed(conn) do
    user = current_user(conn)
    if user do
      NaiveDateTime.diff NaiveDateTime.utc_now, user.inserted_at
    else
      false
    end
  end

  def abort_button(conn) do
    link raw("<i class=\"fas fa-power-off\"></i> Abort"),
      class: "btn btn-outline-danger ml-2",
      to: Routes.session_path(conn, :delete),
      data_confirm: "Are you sure? You will not be able to continue on your contributions and you will not receive any payout!",
      method: "delete"
  end

  def logout_button(conn) do
    link content_tag(:i, "", class: "fas fa-power-off"),
      to: Routes.session_path(conn, :delete),
      class: "nav-link text-light",
      data_toggle: "tooltip",
      method: "delete",
      title: "Sign Out"
  end

  def home_button(conn) do
    text = raw("<i class=\"far fa-lightbulb mr-1\"></i>Idea Nexus")

    if current_user(conn) do
      link text,
        to: Routes.topic_path(conn, :show),
        class: "navbar-brand d-none d-md-block"
    else
      link text,
        to: Routes.user_path(conn, :new),
        class: "navbar-brand"
    end
  end

  def timer_button(conn) do
    started = current_user(conn).inserted_at
    minTime = Application.fetch_env!(:collaboration, :minTime)
    countdown = NaiveDateTime.diff(started, NaiveDateTime.utc_now()) + minTime

    if countdown <= 0 do
      button "Complete Experiment",
        id: "timer",
        class: "btn btn-success",
        data_confirm: "Are you sure? This will move you to the survey!",
        to: Routes.user_path(conn, :finish)
    else
      timeElement = content_tag :time, "",
        datetime: date(NaiveDateTime.add(started, minTime ))

      button timeElement,
        id: "timer",
        class: "btn btn-light",
        data_confirm: "Are you sure? This will move you to the survey!",
        data_remaining: countdown,
        disabled: true,
        to: Routes.user_path(conn, :finish)
    end
  end

  def get_user(conn) do
    if conn.assigns.current_user do
      Jason.encode!(
        %{
          condition: conn.assigns.current_user.condition,
          ideas: get_user_ideas!(conn.assigns.current_user.id),
          comments: get_user_comments!(conn.assigns.current_user.id)
        },
        escape: :javascript_safe
      )
    else
      nil
    end
  end

  def render_current_user(conn) do
    if current_user(conn) do
    Phoenix.View.render_one current_user(conn), UserView, "user.json"

    else
      Jason.encode!(nil)
    end
  end
end
