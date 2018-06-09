defmodule CollaborationWeb.UserChannel do
  use CollaborationWeb, :channel

  def join("user" <> _user_id, _params, socket) do
    if user?(socket), do: {:ok, %{}, socket},
    else: {:error, %{}}
  end
end
