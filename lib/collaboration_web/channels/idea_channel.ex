defmodule CollaborationWeb.IdeaChannel do
  use CollaborationWeb, :channel
  import Collaboration.Contributions
  alias Phoenix.View
  alias CollaborationWeb.CommentView

  def join("idea:"<> id, params, socket) do
    last_seen_id = params["last_seen_id"] || 0
    idea_id = String.to_integer(id)
    comments = list_comments(idea_id, last_seen_id)
    resp = %{
      comments: View.render_many(comments, CommentView, "comment.json",
        current_user: Map.get(socket.assigns, :user_id, nil)
      )
    }
    {:ok, resp, assign(socket, :idea_id, idea_id)}
  end

  def handle_in("new:feedback", data, socket) do
    if authenticated?(socket) do
      case create_comment(socket.assigns[:user], socket.assigns[:idea_id], data) do
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

  def handle_in("rate", %{"rating" => rating}, socket) do
    if authenticated?(socket) do
      rate_idea!(socket.assigns[:user], socket.assigns[:idea_id], %{rating: rating})
      {:noreply, socket}
    else
      {:reply, {:error, %{}}, socket}
    end
  end

  def handle_in("like:feedback", %{"comment" => id}, socket) do
    if authenticated?(socket) do
      like_comment(socket.assigns[:user], id)
      {:reply, {:ok, %{}}, socket}
    else
      {:reply, {:error, %{}}, socket}
    end
  end

  def handle_in("unlike:feedback", %{"comment" => id}, socket) do
    if authenticated?(socket) do
      unlike_comment(socket.assigns[:user], id)
      {:reply, {:ok, %{}}, socket}
    else
      {:reply, {:error, %{}}, socket}
    end
  end

  def handle_in("update:fake_likes", %{"comment" => id} = params, socket) do
    if authenticated?(socket) do
      get_comment!(id) |> update_comment(params)
      {:reply, {:ok, %{}}, socket}
    else
      {:reply, {:error, %{}}, socket}
    end
  end

  defp authenticated?(socket), do: Map.has_key? socket.assigns, :user
  defp admin?(socket), do: authenticated?(socket) && socket.assigns.user.admin
end
