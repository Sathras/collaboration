defmodule CollaborationWeb.IdeaChannel do
  use CollaborationWeb, :channel
  import Collaboration.Contributions

  def join("idea:"<> id, _, socket) do
    {:ok, assign(socket, :idea, get_idea!(id))}
  end

  def handle_in("new:feedback", data, socket) do
    if authenticated?(socket) do
      case create_comment(socket.assigns[:user], socket.assigns[:idea], data) do
      {:ok, comment} ->
        broadcast! socket, "new:feedback", %{
          id: comment.id,
          author: socket.assigns.user.name,
          text: comment.text,
          time: comment.inserted_at
        }
        {:reply, {:ok, %{}}, socket}
      {:error, _changeset} ->
        {:reply, {:error, %{
          reason: dgettext("coherence", "Invalid form data.")}},
          socket}
      end

    else
      {:reply, {:error, %{
        reason: dgettext("coherence", "You are not authorized.")}},
        socket}
    end
  end

  def handle_in("delete:feedback", %{"id" => id}, socket) do
    if admin?(socket) do
      case get_comment!(id) |> delete_comment do
      {:ok, _comment} ->
        broadcast! socket, "delete:feedback", %{ id: id }
        {:noreply, socket}
      {:error, _changeset} ->
        {:noreply, socket}
      end
    else
      {:reply, {:error, %{
        reason: dgettext("coherence", "You are not authorized.")}},
        socket}
    end
  end

  defp authenticated?(socket), do: Map.has_key? socket.assigns, :user
  defp admin?(socket), do: authenticated?(socket) && socket.assigns.user.admin
end
