defmodule CollaborationWeb.PublicChannel do
  use CollaborationWeb, :channel

  def join("public", _params, socket), do: {:ok, %{}, socket}
end