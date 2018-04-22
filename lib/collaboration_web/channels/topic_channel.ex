defmodule CollaborationWeb.TopicChannel do
  use CollaborationWeb, :channel
  import Collaboration.Coherence.Schemas
  import Collaboration.Contributions

  alias Phoenix.View
  alias CollaborationWeb.Endpoint
  alias CollaborationWeb.IdeaView

  def join("topic:"<> id, params, socket) do
    last_seen_id = params["last_seen_id"] || 0
    topic = get_topic!(id)
    ideas = list_ideas(topic.id, last_seen_id)
    user_id = if authorized?(socket), do: socket.assigns.user.id, else: nil
    resp = %{ ideas: render_ideas(ideas, user_id) }
    {:ok, resp, assign(socket, :topic, topic)}
  end

  def handle_in("new:idea", data, socket) do
    if authorized?(socket) do
      case create_idea(socket.assigns.user, socket.assigns.topic, data) do
        {:ok, idea} ->
          idea = get_idea_details(idea)
          # broadcast idea to topic channel
          broadcast! socket, "new:idea", View.render_one(idea, IdeaView, "idea.json")

          # if topic is displayed in navbar also broadcast it to public channel
          topic = socket.assigns.topic
          if topic.featured && topic.published, do:
            Endpoint.broadcast! "public", "new:idea", %{id: topic.id}

          Task.Supervisor.async_nolink(Collaboration.TaskSupervisor, fn ->
            :timer.sleep(30000)
            create_feedback(idea)
          end)

          {:reply, {:ok, %{}}, socket}
        {:error, changeset} ->
          {:reply, {:error, %{ errors: error_map(changeset) }}, socket}
      end
    else
      {:reply, {:error, %{}}, socket}
    end
  end

  def create_feedback(idea) do
    # choose a random feedback user
    user = get_random_feedback_user()
    if user do
      case create_comment(user, idea, %{"text" => "Great feedback, thanks!"}) do
        {:ok, comment} ->
          # update idea and topic channels
          Endpoint.broadcast! "idea:#{idea.id}", "new:feedback", render_comment(comment)
          Endpoint.broadcast! "topic:#{idea.topic_id}", "update:idea", render_idea(comment.idea_id)
          :ok
        _ ->
          :error
      end
    else
      :error
    end
  end

  def handle_in("update:idea", data, socket) do
    if authorized?(socket) do
      case get_idea!(data["id"]) |> update_idea(data) do
        {:ok, idea} ->
          idea = get_idea_details(idea)
          broadcast! socket, "update:idea", View.render_one(idea, IdeaView, "idea.json")
          {:reply, {:ok, %{}}, socket}
        {:error, changeset} ->
          {:reply, {:error, %{ errors: error_map(changeset) }}, socket}
      end
    else
      {:reply, {:error, %{}}, socket}
    end
  end

  def handle_in("delete:idea", %{"id" => id}, socket) do
    if admin?(socket) do
      case get_idea!(id) |> delete_idea do
      {:ok, _idea} ->
        broadcast! socket, "delete:idea", %{ id: id }
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

  defp authorized?(socket), do:
    Map.has_key?(socket.assigns, :user) && (
      socket.assigns.user.admin || socket.assigns.topic.open
    )
end