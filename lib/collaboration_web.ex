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

  def channel do
    quote do
      use Phoenix.Channel
    end
  end

  def controller do
    quote do
      use Phoenix.Controller, namespace: CollaborationWeb

      import Plug.Conn
      import CollaborationWeb.ViewHelpers

      alias CollaborationWeb.Router.Helpers, as: Routes
    end
  end

  def view do
    quote do
      use Phoenix.View,
        root: "lib/collaboration_web/templates",
        namespace: CollaborationWeb

      # Import convenience functions from controllers
      import Collaboration.Accounts, only: [condition: 1]
      import Collaboration.Contributions, only: [future: 1, remaining: 1]

      # Use all HTML functionality (forms, tags, etc)
      use Phoenix.HTML

      import Phoenix.HTML.Form, except: [textarea: 3]

      import CollaborationWeb.ErrorHelpers
      import CollaborationWeb.ViewHelpers

      alias Phoenix.View
      alias CollaborationWeb.Router.Helpers, as: Routes
      alias CollaborationWeb.{ CommentView, IdeaView, TopicView, Endpoint }
    end
  end

  def router do
    quote do
      use Phoenix.Router
      import Plug.Conn
      import Phoenix.Controller
      import CollaborationWeb.Auth, only: [authenticate_user: 2, authenticate_admin: 2]
      import CollaborationWeb.TopicController, only: [add_topic: 2]
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
