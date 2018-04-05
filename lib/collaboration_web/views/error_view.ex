defmodule CollaborationWeb.ErrorView do
  use CollaborationWeb, :view

  # If you want to customize a particular status code
  # for a certain format, you may uncomment below.
  def render("401.html", _assigns), do: render "401.html"
  def render("403.html", _assigns), do: render "403.html"
  def render("404.html", _assigns), do: render "404.html"
  def render("500.html", _assigns), do: render "500.html"

  # By default, Phoenix returns the status message from
  # the template name. For example, "404.html" becomes
  # "Not Found".
  def template_not_found(_template, _assigns) do
    # Phoenix.Controller.status_message_from_template(template)
    render "500.html"
  end
end
