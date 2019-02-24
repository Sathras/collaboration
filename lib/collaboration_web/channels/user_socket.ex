defmodule CollaborationWeb.UserSocket do
  use Phoenix.Socket

  import Collaboration.Accounts, only: [get_user: 1]
  import Collaboration.Contributions, only: [get_featured_topic_id!: 0]

  channel "topic", CollaborationWeb.TopicChannel

  @max_age 2 * 60 * 60 # token is valid for 2 hours

  def connect(%{"token" => token}, socket) do
    case Phoenix.Token.verify(socket, "user socket", token, max_age: @max_age) do
      {:ok, user_id} ->
        socket = socket
        |> assign(:topic_id, get_featured_topic_id!())
        |> assign(:user, get_user(user_id))
        {:ok, socket}

      {:error, _reason} ->
        :error
    end
  end

  def connect(_params, _socket), do: :error

  def id(_socket), do: nil
end
