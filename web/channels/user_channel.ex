defmodule Collaboration.UserChannel do
  use Collaboration.Web, :channel

  def join("user", params, socket) do
    {:ok, socket}
  end


end