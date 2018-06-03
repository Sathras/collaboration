defmodule CollaborationWeb do
  @moduledoc """
  The entrypoint for defining your web interface, such
  as controllers, views, channels and so on.

  This can be used in your application as:

      use CollaborationWeb, :controller
      use CollaborationWeb, :view

  The definitions below will be executed for every view,
  controller, etc, so keep them short and clean, focused
  on imports, uses and aliases.

  Do NOT define functions inside the quoted expressions
  below. Instead, define any helper function in modules
  and import those modules here.
  """

  def controller do
    quote do
      use Phoenix.Controller, namespace: CollaborationWeb
      import Plug.Conn
      import Collaboration.Contributions
      import CollaborationWeb.Router.Helpers
      import CollaborationWeb.Gettext
      import Coherence, only: [current_user: 1]
    end
  end

  def commander do
    quote do
      use Drab.Commander, modules: [Drab.Element, Drab.Live, Drab.Query]
      import Collaboration.Coherence.Schemas
      import Collaboration.Contributions
    end
  end

  def view do
    quote do
      use Phoenix.View,
        root: "lib/collaboration_web/templates",
        namespace: CollaborationWeb

      # Import convenience functions from controllers
      import Phoenix.Controller, only: [
        action_name: 1,
        get_flash: 2,
        view_module: 1
      ]

      # Use all HTML functionality (forms, tags, etc)
      use Phoenix.HTML
      use PhoenixHtmlSanitizer, :full_html

      import CollaborationWeb.Router.Helpers
      import CollaborationWeb.ErrorHelpers
      import CollaborationWeb.ViewHelpers
      import CollaborationWeb.Gettext
      import Coherence, only: [current_user: 1]

      alias CollaborationWeb.TopicView
      alias CollaborationWeb.IdeaView
      alias CollaborationWeb.CommentView
    end
  end

  def router do
    quote do
      use Phoenix.Router
      import Plug.Conn
      import Phoenix.Controller
    end
  end

  def channel do
    quote do
      use Phoenix.Channel
      import CollaborationWeb.Gettext
      import CollaborationWeb.ErrorHelpers

      import CollaborationWeb.UserSocket,
        only: [user?: 1, admin?: 1, user_id: 1]
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
