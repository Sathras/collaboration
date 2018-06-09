defmodule CollaborationWeb.Coherence.ViewHelpers do
  @moduledoc """
  Helper functions for Coherence Views.
  """
  use Phoenix.HTML
  import CollaborationWeb.Gettext
  import CollaborationWeb.ViewHelpers

  @type conn :: Plug.Conn.t()
  @type schema :: Ecto.Schema.t()

  @helpers CollaborationWeb.Router.Helpers

  @recover_link dgettext("coherence", "Forgot password?")
  @unlock_link dgettext("coherence", "Send an unlock email")
  @register_link dgettext("coherence", "Join Us")
  @invite_link dgettext("coherence", "Invite Someone")
  @confirm_link dgettext("coherence", "Confirm Account")
  @settings_link dgettext("coherence", "Settings")

  @doc """
  Helper to avoid compile warnings when options are disabled.
  """
  @spec coherence_path(module, atom, conn, atom) :: String.t()
  def coherence_path(module, route_name, conn, action) do
    apply(module, route_name, [conn, action])
  end

  def coherence_path(module, route_name, conn, action, opts) do
    apply(module, route_name, [conn, action, opts])
  end

  @spec recover_link(conn, module, false | String.t()) :: [any] | []
  def recover_link(_conn, _user_schema, false), do: []

  def recover_link(conn, user_schema, text) do
    if user_schema.recoverable?, do: [recover_link(conn, text)], else: []
  end

  @spec recover_link(conn, String.t()) :: tuple
  def recover_link(conn, text \\ @recover_link),
    do: link(text, to: coherence_path(@helpers, :password_path, conn, :new))

  @spec register_link(conn, module, false | String.t()) :: [any] | []
  def register_link(_conn, _user_schema, false), do: []

  def register_link(conn, user_schema, text) do
    if user_schema.registerable?, do: [register_link(conn, text)], else: []
  end

  @spec register_link(conn, String.t()) :: tuple
  def register_link(conn, text \\ @register_link),
    do: link(text, to: coherence_path(@helpers, :registration_path, conn, :new))

  @spec unlock_link(conn, module, false | String.t()) :: [any] | []
  def unlock_link(_conn, _user_schema, false), do: []

  def unlock_link(conn, _user_schema, text) do
    if conn.assigns[:locked], do: [unlock_link(conn, text)], else: []
  end

  @spec unlock_link(conn, String.t()) :: tuple
  def unlock_link(conn, text \\ @unlock_link),
    do: link(text, to: coherence_path(@helpers, :unlock_path, conn, :new))

  @spec invitation_link(conn, String.t()) :: tuple
  def invitation_link(conn, text \\ @invite_link) do
    link(text, to: coherence_path(@helpers, :invitation_path, conn, :new))
  end

  @spec settings_link(conn, module, false | String.t()) :: [any] | []
  def settings_link(_conn, _user_schema, false), do: []

  def settings_link(conn, user_schema, text) do
    if user_schema.registerable?, do: [settings_link(conn, text)], else: []
  end

  @spec settings_link(conn, false | String.t()) :: tuple
  def settings_link(conn, text \\ @settings_link) do
    to = coherence_path(@helpers, :registration_path, conn, :edit)
    if text, do: link(text, to: to), else: link(icon("fas fa-cog"), to: to)
  end

  @spec confirmation_link(conn, module, false | String.t()) :: [any] | []
  def confirmation_link(_conn, _user_schema, false), do: []

  def confirmation_link(conn, user_schema, text) do
    if user_schema.confirmable?, do: [confirmation_link(conn, text)], else: []
  end

  @spec confirmation_link(conn, String.t()) :: tuple
  def confirmation_link(conn, text \\ @confirm_link) do
    link(text, to: coherence_path(@helpers, :confirmation_path, conn, :new))
  end

  @spec required_label(atom, String.t() | atom, Keyword.t()) :: tuple
  def required_label(f, name, opts \\ []) do
    label f, name, opts do
      [
        "#{humanize(name)}\n",
        content_tag(:abbr, "*", class: "required", title: "required")
      ]
    end
  end

  @spec current_user(conn) :: schema
  def current_user(conn) do
    Coherence.current_user(conn)
  end

  @spec logged_in?(conn) :: boolean
  def logged_in?(conn) do
    Coherence.logged_in?(conn)
  end

  @doc """
  Translates an error message using gettext.
  """
  def translate_error({msg, opts}) do
    # Because error messages were defined within Ecto, we must
    # call the Gettext module passing our Gettext backend. We
    # also use the "errors" domain as translations are placed
    # in the errors.po file.
    # Ecto will pass the :count keyword if the error message is
    # meant to be pluralized.
    # On your own code and templates, depending on whether you
    # need the message to be pluralized or not, this could be
    # written simply as:
    #
    #     dngettext "errors", "1 file", "%{count} files", count
    #     dgettext "errors", "is invalid"
    #
    if count = opts[:count] do
      Gettext.dngettext(
        CollaborationWeb.Gettext,
        "errors",
        msg,
        msg,
        count,
        opts
      )
    else
      Gettext.dgettext(CollaborationWeb.Gettext, "errors", msg, opts)
    end
  end

  @doc """
  Generates an error string from changeset errors.
  """
  def error_string_from_changeset(changeset) do
    Enum.map(changeset.errors, fn {k, v} ->
      "#{Phoenix.Naming.humanize(k)} #{translate_error(v)}"
    end)
    |> Enum.join(". ")
  end
end
