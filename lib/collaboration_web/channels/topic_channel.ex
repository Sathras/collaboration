defmodule CollaborationWeb.TopicChannel do
  use CollaborationWeb, :channel

  def join("topic", _params, socket) do

    # schedule spawning of new posts
    send(self, :after_join)

    {:ok, socket}
  end

  def handle_info(:after_join, socket) do

    schedule_idea(socket, "test", 5)
    schedule_idea(socket, "test", 6)
    schedule_idea(socket, "test", 7)

    {:noreply, socket}
  end

  defp schedule_idea(socket, _idea, time) do
    spawn(fn -> :timer.sleep(time * 1000);
      push(socket, "test", %{time: time})
    end)
  end
end
