defmodule CollaborationWeb.UserSocket do
  use Phoenix.Socket

  channel "topic", CollaborationWeb.TopicChannel

  @max_age 2 * 60 * 60 # token is valid for 2 hours

  def connect(%{"token" => token}, socket) do
    case Phoenix.Token.verify(socket, "user socket", token, max_age: @max_age) do
      {:ok, user_id} ->
        {:ok, assign(socket, :user, Collaboration.Accounts.get_user(user_id))}

      {:error, _reason} ->
        :error
    end
  end

  def connect(_params, _socket), do: :error

  def id(_socket), do: nil

  @doc """
  Sends event to the socket after a specified amount of time [s].

  ## Examples

      iex> push(socket, "test", 3000, %{
        msg: "This message should appear after 3 seconds."
      })
      :ok

  """
  @spec schedule(Socket.t, String.t, integer, map()) :: :ok
  def schedule(socket, event, delay, data \\ %{}) do
    spawn(fn ->
      :timer.sleep(delay * 1000);
      Phoenix.Channel.push(socket, event, data)
    end)
    :ok
  end
end
