defmodule CollaborationWeb.UserSocket do
  use Phoenix.Socket

  channel "topic", CollaborationWeb.TopicChannel

  @max_age 2 * 60 * 60 # token is valid for 2 hours

  def connect(%{"token" => token}, socket) do
    case Phoenix.Token.verify(socket, "user socket", token, max_age: @max_age) do
      {:ok, user_id} ->
        {:ok, assign(socket, :user_id, user_id)}

      {:error, _reason} ->
        :error
    end
  end

  def connect(_params, _socket), do: :error

  def id(_socket), do: nil
end
