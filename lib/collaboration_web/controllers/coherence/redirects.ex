defmodule Coherence.Redirects do
  @moduledoc """
  Define controller action redirection functions.

  This module contains default redirect functions for each of the controller
  actions that perform redirects. By using this Module you get the following
  functions:

  * session_create/2
  * session_delete/2
  * password_create/2
  * password_update/2,
  * registration_create/2
  * invitation_create/2

  You can override any of the functions to customize the redirect path. Each
  function is passed the `conn` and `params` arguments from the controller.

  """
  use Redirects

  alias CollaborationWeb.Router.Helpers, as: Routes

  def registration_create(conn, _),
    do: redirect(conn, to: Routes.session_path(conn, :new))

  def session_delete(conn, _),
    do: redirect(conn, to: Routes.user_path(conn, :complete))
end
