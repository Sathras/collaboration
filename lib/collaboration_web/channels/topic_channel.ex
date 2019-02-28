defmodule CollaborationWeb.TopicChannel do
  use CollaborationWeb, :channel

  import Phoenix.View, only: [render_to_string: 3]
  alias CollaborationWeb.{ IdeaView, CommentView }

  def join("topic", _params, socket) do

    # schedule spawning of pregenerated, delayed ideas and comments
    send self(), :after_join

    {:ok, socket}
  end

  def handle_info(:after_join, socket) do
    user = socket.assigns.user

    # get ideas that should be posted in the future (experiment users only)
    if user.condition > 0 do

      idea_ids = get_idea_ids!(socket.assigns.topic_id, user)
      # user_ids = idea_ids
      # |> Enum.to_list()
      # |> Enum.filter(fn { _, user_id } -> user_id == user.id end)
      # |> Enum.map(fn { id, _ } -> id end)

      # TODO: load and post future bot-to-user interactions


      # load and post future ideas
      ideas = load_future_ideas(socket.assigns.topic_id, user)
      for idea <- ideas do
        schedule_idea socket, idea
      end

      # load and post future comments
      idea_ids = Enum.map(idea_ids, fn { id, _ } -> id end)
      comments = load_future_comments(idea_ids, user)
      for comment <- comments do
        schedule_comment socket, comment
      end
    end

    {:noreply, socket}
  end

  def handle_in("create_idea", params, socket) do
    params = Map.put params, "user_id", socket.assigns.user.id
    case create_idea(params, socket.assigns.topic_id, socket.assigns.user) do
      idea ->
        idea = render_to_string IdeaView, "idea.html",
          idea: idea,
          user: socket.assigns.user

        {:reply, {:ok, %{ idea: idea }}, socket}

      _error ->
        {:reply, :error, socket}
    end
  end

  def handle_in("create_comment", params, socket) do
    params = Map.put params, "user_id", socket.assigns.user.id
    case create_comment(params) do
      {:ok, comment} ->
        comment = render_to_string(CommentView, "comment.html",
          comment: load_comment(comment, socket.assigns.user),
          user: socket.assigns.user
        )
        {:reply, {:ok, %{ comment: comment }}, socket}

      {:error, _changeset} ->
        {:reply, :error, socket}
    end
  end

  def handle_in("rate_idea", %{"id" => id, "rating" => rating }, socket) do
    case rate_idea rating, id, socket.assigns.user.id do
      {:ok, _rating} ->
        {:reply, :ok, socket}
      {:error, _} ->
        {:reply, :error, socket}
    end
  end

  def handle_in("unrate_idea", %{"id" => id }, socket) do
    case unrate_idea id, socket.assigns.user.id do
      {:ok, _rating} ->
        {:reply, :ok, socket}
      {:error, _} ->
        {:reply, :error, socket}
    end
  end

  def handle_in("like", %{"comment_id" => id, "like" => like }, socket) do
    case like_comment socket.assigns.user, id, like do
      {:ok, _comment} ->
        {:reply, :ok, socket}
      {:error, _} ->
        {:reply, :error, socket}
    end
  end

  defp schedule_idea(socket, idea) do
    spawn(fn -> :timer.sleep(idea.remaining * 1000);
      push socket, "post_idea", %{
        idea: render_to_string(IdeaView, "idea.html",
          idea: idea,
          user: socket.assigns.user
        )
      }
    end)
  end

  defp schedule_comment(socket, comment) do
    spawn(fn -> :timer.sleep(comment.remaining * 1000);
      push socket, "post_comment", %{
        idea_id: comment.idea_id,
        comment: render_to_string(CommentView, "comment.html",
          comment: comment,
          user: socket.assigns.user
        )
      }
    end)
  end
end
# create automated feedback (if not admin or in condition 1 and 2
# if !user.admin && user.condition in [3,4] do
#   Task.Supervisor.async_nolink(Collaboration.TaskSupervisor, fn ->
#     # wait for a little amount of time
#     :timer.sleep Enum.random(5000..10000)
#     # then create an automated feedback
#     sequence = user.feedback_sequence
#     feedback = case sequence do
#       0 -> "1. Automated Feedback"
#       1 -> "2. Automated Feedback"
#       2 -> "3. Automated Feedback"
#       3 -> "4. Automated Feedback"
#       4 -> "5. Automated Feedback"
#       5 -> "6. Automated Feedback"
#       6 -> "7. Automated Feedback"
#       7 -> "8. Automated Feedback"
#       8 -> "9. Automated Feedback"
#       9 -> "10. Automated Feedback"
#     end
#     # create automated feedback
#     random_user = select_random_user(user.id)
#     case create_comment(random_user, user, idea, %{text: feedback}) do
#       {:ok, comment} ->
#         # broadcast back to user
#         Endpoint.broadcast("user:" <> user.id, "new_feedback", %{
#           idea_id: idea.id,
#           comment: render_to_string(CommentView, "comment.html",
#             admin: user.admin,
#             comment: load_comment(comment.id, user),
#             user_id: user.id
#           )
#         })
#     end
#     # increase_feedback_sequence user
#     sequence = if sequence === 9, do: 0, else: sequence + 1
#     update_user(user, %{feedback_sequence: sequence})
#   end)
# end
