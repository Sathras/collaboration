defmodule CollaborationWeb.AdminUsersChannel do
  use CollaborationWeb, :channel
  import Collaboration.Coherence.Schemas

  def join("admin:users", _params, socket) do
    if admin?(socket) do
      {:ok, %{ users: render_users() }, socket}
    else
      {:error, socket}
    end
  end

  def handle_in("toggle", %{"user" => id, "field" => field}, socket) do
    user = get_user!(id)
    case toggle(user, %{field => !Map.get(user, String.to_atom(field))}) do
      {:ok, user} ->
        broadcast! socket, "update:user", render_user(user)
        {:reply, {:ok, %{}}, socket}
      {:error, _} ->
        {:reply, {:error, %{}}, socket}
    end
  end
end