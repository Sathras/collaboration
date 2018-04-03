defmodule CollaborationWeb.ViewHelpers do
  @moduledoc """
  Conveniences that can be used in any views and templates.
  """

  use Phoenix.HTML

  # displays a FontAwesome 5 icon
  def icon(class), do: content_tag(:i, "", class: class)

end