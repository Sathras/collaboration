defmodule CollaborationWeb.IdeaChannel do
  use CollaborationWeb, :channel
  import Collaboration.Contributions
  alias Phoenix.View
  alias CollaborationWeb.IdeaView
  alias CollaborationWeb.CommentView
  alias CollaborationWeb.Endpoint

  def join("idea:"<> id, params, socket) do
    last_seen_id = params["last_seen_id"] || 0
    idea = get_idea!(id)
    comments = list_comments(idea.id, last_seen_id)
    resp = %{
      comments: View.render_many(comments, CommentView, "comment.json",
        current_user: Map.get(socket.assigns, :user_id, nil)
      )
    }
    {:ok, resp, assign(socket, :idea, idea)}
  end

  def handle_in("new:feedback", data, socket) do
    if user?(socket) do
      case create_comment(socket.assigns.user, socket.assigns.idea, data) do
      {:ok, comment} ->
        idea = render_idea(comment.idea_id)
        # update idea and topic channels
        broadcast! socket, "new:feedback", render_comment(comment)
        Endpoint.broadcast! "topic:#{idea.topic_id}", "update:idea", idea
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
      {:ok, comment} ->

        # update idea channel
        broadcast! socket, "delete:feedback", %{ id: id }

        # update topic channel
        idea = get_idea!(comment.idea_id) |> get_idea_details()
        Endpoint.broadcast! "topic:#{idea.topic_id}", "update:idea",
          View.render_one(idea, IdeaView, "idea.json")

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
    if user?(socket) do
      rate_idea!(socket.assigns[:user], socket.assigns.idea, %{rating: rating})
      idea = render_idea socket.assigns.idea.id
      Endpoint.broadcast! "topic:#{idea.topic_id}", "update:idea", idea
      {:reply, {:ok, %{}}, socket}
    else
      {:reply, {:error, %{}}, socket}
    end
  end

  def handle_in("like:feedback", %{"comment" => id}, socket) do
    if user?(socket) do
      case like_comment(socket.assigns.user, id) do
        {:ok, comment} ->
          broadcast! socket, "update:feedback", View.render_one(
            get_comment_details(comment), CommentView, "comment.json",
            current_user: nil)
          {:reply, {:ok, %{}}, socket}
        _ ->
          {:reply, {:error, %{}}, socket}
      end
    else
      {:reply, {:error, %{}}, socket}
    end
  end

  def handle_in("unlike:feedback", %{"comment" => id}, socket) do
    if user?(socket) do
      case unlike_comment(socket.assigns.user, id) do
        {:ok, comment} ->
          broadcast! socket, "update:feedback", View.render_one(
            get_comment_details(comment), CommentView, "comment.json",
            current_user: nil)
          {:reply, {:ok, %{}}, socket}
        _ ->
          {:reply, {:error, %{}}, socket}
      end
    else
      {:reply, {:error, %{}}, socket}
    end
  end

  def handle_in("update:fake_likes", %{"comment" => id} = params, socket) do
    if user?(socket) do
      case get_comment!(id) |> update_comment(params) do
        {:ok, comment} ->
          broadcast! socket, "update:feedback", View.render_one(
            get_comment_details(comment), CommentView, "comment.json",
            current_user: nil)
          {:reply, {:ok, %{}}, socket}
        _ ->
          {:reply, {:error, %{}}, socket}
      end
    else
      {:reply, {:error, %{}}, socket}
    end
  end
end
