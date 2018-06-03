defmodule CollaborationWeb.UserSocket do
  use Phoenix.Socket
  use Drab.Socket

  ## Channels
  channel("public", CollaborationWeb.PublicChannel)
  channel("topic:*", CollaborationWeb.TopicChannel)
  channel("admin:users", CollaborationWeb.AdminUsersChannel)

  ## Transports
  transport(:websocket, Phoenix.Transports.WebSocket)

  # connecting with user token
  # def connect(%{"token" => token}, socket) do
  #   case Token.verify(socket, "user socket", token, max_age: @max_age) do
  #     {:ok, id} ->
  #       socket = socket
  #       |> assign(:user_id, id)
  #       |> assign(:admin, is_admin?(id))
  #       {:ok, socket}
  #     {:error, _reason} -> :error
  #   end
  # end

  # connecting without user token
  def connect(_params, socket), do: {:ok, socket}

  # identify socket
  def id(_socket), do: nil

  def user_id(socket), do: Map.get(socket.assigns, :user_id, nil)
  def user?(socket), do: Map.has_key?(socket.assigns, :user_id)
  def admin?(socket), do: Map.get(socket.assigns, :admin, false)
end
