defmodule CollaborationWeb.UserSocket do
  use Phoenix.Socket
  use Drab.Socket

  import Coherence.Config, only: [rememberable_cookie_expire_hours: 0]
  import Collaboration.Coherence.Schemas, only: [is_admin?: 1]

  alias Phoenix.Token

  @max_age rememberable_cookie_expire_hours() * 60 * 60 || ( 2 * 24 * 60 * 60 )

  # connecting with user token
  def connect(%{"user_token" => token}, socket) do
    case Token.verify(socket, "user socket", token, max_age: @max_age) do
      {:ok, id} -> {:ok, assign(socket, :user_id, id)}
      {:error, _reason} -> :error
    end
  end

  # connecting without user token
  def connect(_params, socket), do: {:ok, socket}
  def connect(_params, socket, _), do: {:ok, socket}

  # identify socket
  def id(socket) do
    if Map.has_key?(socket.assigns, :user_id),
      do: "user:#{socket.assigns.user_id}",
      else: nil
  end
end
