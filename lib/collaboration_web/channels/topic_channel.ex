defmodule CollaborationWeb.TopicChannel do
  use CollaborationWeb, :channel
  import Collaboration.Coherence.Schemas
  import Collaboration.Contributions

  alias Phoenix.View
  alias CollaborationWeb.Endpoint
  alias CollaborationWeb.IdeaView

  def join("topic:" <> id, params, socket) do
    last_seen_id = params["last_seen_id"] || 0
    topic = get_topic!(id)
    user = Map.get(socket.assigns, :user, nil)
    resp = %{ideas: list_ideas(topic.id, last_seen_id, user)}
    {:ok, resp, assign(socket, :topic, topic)}
  end

  def handle_in("new:idea", data, socket) do
    if contributeable?(socket) do

      topic = socket.assigns.topic

      case create_idea socket.assigns.user, topic, data do
        {:ok, idea} ->

          # broadcast public ideas to everyone viewing the topic
          broadcast! socket, "new:idea", render_idea(idea, nil)

          # if topic is displayed in navbar also broadcast to public channel
          if topic.featured && topic.published do
            Endpoint.broadcast! "public", "new:idea", %{
              id: idea.id,
              open: idea.public
            }
          end

          Task.Supervisor.async_nolink(Collaboration.TaskSupervisor, fn ->
            :timer.sleep(30000)
            create_feedback(idea, socket.assigns.user)
          end)

          {:reply, {:ok, %{}}, socket}

        {:error, changeset} ->
          {:reply, {:error, %{errors: error_map(changeset)}}, socket}
      end
    else
      {:reply, {:error, %{}}, socket}
    end
  end

  def handle_in("update:idea", data, socket) do
    if contributeable?(socket) do
      case get_idea!(data["id"]) |> update_idea(data) do
        {:ok, idea} ->
          idea = get_idea_details(idea)

          broadcast!(
            socket,
            "update:idea",
            View.render_one(idea, IdeaView, "idea.json", user: nil)
          )

          {:reply, {:ok, %{}}, socket}

        {:error, changeset} ->
          {:reply, {:error, %{errors: error_map(changeset)}}, socket}
      end
    else
      {:reply, {:error, %{}}, socket}
    end
  end

  def handle_in("delete:idea", %{"id" => id}, socket) do
    if admin?(socket) do
      case get_idea!(id) |> delete_idea do
        {:ok, _idea} ->
          broadcast!(socket, "delete:idea", %{id: id})
          {:noreply, socket}

        {:error, _changeset} ->
          {:noreply, socket}
      end
    else
      {:reply,
       {:error, %{reason: dgettext("coherence", "You are not authorized.")}},
       socket}
    end
  end

  defp create_feedback(idea, recipient) do
    # choose a random feedback user
    author = get_random_feedback_user()

    if author do
      case create_comment(author, recipient, idea, %{
             "text" => "Great feedback, thanks!"
           }) do
        {:ok, comment} ->
          # update idea and topic channels
          Endpoint.broadcast!(
            "idea:#{idea.id}",
            "new:feedback",
            render_comment(comment)
          )

          Endpoint.broadcast!(
            "topic:#{idea.topic_id}",
            "update:idea",
            render_idea(comment.idea_id, nil)
          )

          :ok

        _ ->
          :error
      end
    else
      :error
    end
  end

  defp contributeable?(socket) do
    cond do
      admin?(socket) ->
        true

      user?(socket) && socket.assigns.topic.open &&
          socket.assigns.topic.published ->
        true

      true ->
        false
    end
  end
end
