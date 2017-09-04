defmodule Collaboration.PublicChannel do
  use Collaboration.Web, :channel

  def join("public", _params, socket) do
    {:ok, socket}
  end
end