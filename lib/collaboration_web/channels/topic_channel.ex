defmodule CollaborationWeb.TopicChannel do
  use CollaborationWeb, :channel

  def join("topic", _params, socket) do

    # schedule spawning of pregenerated, delayed ideas and comments
    send(self, :after_join)

    {:ok, socket}
  end

  def handle_info(:after_join, socket) do

    # get ideas that should be posted in the future (experiment users only)
    if socket.assigns.user.condition > 0 do
      ideas = load_future_ideas(socket.assigns.topic_id, socket.assigns.user)
      for idea <- ideas do
        schedule_idea socket, idea
      end

      # comments = load_future_comments(socket.assigns.topic_id, socket.assigns.user)
    end

    {:noreply, socket}
  end

  defp schedule_idea(socket, idea) do
    spawn(fn -> :timer.sleep(idea.remaining * 1000);
      push socket, "post_idea", idea
    end)
  end
end
