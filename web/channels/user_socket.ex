defmodule Collaboration.UserSocket do
  use Phoenix.Socket

  ## Channels
  channel "admin", Collaboration.AdminChannel
  channel "topic:*", Collaboration.TopicChannel

  ## Transports
  transport :websocket, Phoenix.Transports.WebSocket
  # transport :longpoll, Phoenix.Transports.LongPoll

  @max_age 2 * 7 * 24 * 60 * 60

  def connect(%{"token" => token}, socket) do
    case Phoenix.Token.verify(socket, "user socket", token, max_age: @max_age) do
      {:ok, user_id} ->

        user = Collaboration.Repo.get!(Collaboration.User, user_id)
        socket =
          socket
          |> assign(:user_id, user_id)
          |> assign(:admin, user.admin)

        {:ok, socket}
      {:error, _reason} ->
        socket =
          socket
          |> assign(:user_id, nil)
          |> assign(:admin, false)
        {:ok, socket}
    end
  end

  def connect(_params, _socket), do: :error

  def id(_socket), do: nil

end
