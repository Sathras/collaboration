defmodule CollaborationWeb.TopicChannel do
  use CollaborationWeb, :channel

  alias Phoenix.View
  alias CollaborationWeb.{ IdeaView, CommentView }

  def join("topic", _params, socket) do

    # load bot-to-user comments and user_ideas (id and inserted_at)
    socket = socket
    |> assign(:bot_comment_ids, get_future_bot_comment_ids(socket.assigns.user))
    |> assign(:user_idea_ids, get_user_idea_ids(socket.assigns.topic_id, socket.assigns.user.id))

    {:ok, %{
      ideas: get_idea_schedule(socket),       # get ideas to be published
      comments: get_comment_schedule(socket)  # get comments to be published
    }, socket}
  end

  def handle_in("create_idea", params, socket) do
    params = Map.put params, "user_id", socket.assigns.user.id
    case create_idea(params, socket.assigns.topic_id, socket.assigns.user) do
      {:ok, idea } ->

        # check how many ideas the user has
        # idea_count = count_ideas socket.assigns.user.id
        # case idea_count do
        #   1 -> schedule_first_response_comment(socket, idea.id)
        #   2 -> schedule_second_response_comment(socket, idea.id)
        # end

        idea = View.render_to_string IdeaView, "idea.html",
          idea: View.render_one(idea, IdeaView, "idea.json", user: socket.assigns.user),
          user: socket.assigns.user

        {:reply, {:ok, %{ idea: idea }}, socket}

      { :error, _changeset } ->
        {:reply, :error, socket}
    end
  end

  def handle_in("load_idea", %{"id" => idea_id }, socket) do
    idea = View.render_to_string IdeaView, "idea.html",
      idea: load_idea(idea_id, socket.assigns.user),
      user: socket.assigns.user

    {:reply, {:ok, %{ idea: idea }}, socket}
  end

  def handle_in("load_comment", %{"id" => comment_id }, socket) do
    comment = View.render_to_string CommentView, "comment.html",
      comment: load_comment(comment_id, socket.assigns.user),
      user: socket.assigns.user

    {:reply, {:ok, %{ comment: comment }}, socket}
  end

  def handle_in("create_comment", params, socket) do
    params = Map.put params, "user_id", socket.assigns.user.id
    case create_comment(params) do
      {:ok, comment} ->

        # TODO: check how many comments the user has


        comment = View.render_to_string(CommentView, "comment.html",
          comment: load_comment(comment, socket.assigns.user),
          user: socket.assigns.user
        )
        {:reply, {:ok, %{ comment: comment }}, socket}

      {:error, _changeset} ->
        {:reply, :error, socket}
    end
  end

  def handle_in("rate_idea", %{"id" => id, "rating" => rating }, socket) do
    case rate_idea! rating, id, socket.assigns.user.id do
      %{ "raters" => _, "rating" => _, "my_rating" => _ } = rating ->
        {:reply, {:ok, rating }, socket}
      _->
        {:reply, :error, socket}
    end
  end

  def handle_in("unrate_idea", %{"id" => id }, socket) do
    {:reply, {:ok, unrate_idea!(id, socket.assigns.user.id) }, socket}
  end

  def handle_in("like", %{"comment_id" => id, "like" => like }, socket) do
    case like_comment socket.assigns.user, id, like do
      {:ok, _comment} ->
        {:reply, :ok, socket}
      {:error, _} ->
        {:reply, :error, socket}
    end
  end

  @doc """
    returns a list of ids for automated ideas that have yet to be published

    @param socket
    @return
      list [[ idea_id, remaining ], ...]
      idea_id     = id of idea where to attach it to,
      remaining   = when to attach it to [sec]
  """
  defp get_idea_schedule(socket) do
    get_future_idea_ids!(socket.assigns.topic_id, socket.assigns.user)
  end

  @doc """
    returns a list of ids for automated comments that have yet to be published,
    both bot-to-bot and bot-to-user responses

    @param socket
    @return
      list [[ comment_id, idea_id, remaining ], ...]
      comment_id  = id of comment that needs to be published
      idea_id     = id of idea where to attach it to,
      remaining   = when to attach it to [sec]
  """
  defp get_comment_schedule(socket) do
    time = NaiveDateTime.diff NaiveDateTime.utc_now(), socket.assigns.user.inserted_at

    r_ids = idea_response_ids(socket)

    bot_to_user_comments = Enum.map(r_ids, fn response_id ->

        # find the time after which a bot comment should be posted
        {_, remaining } = Enum.find(socket.assigns.bot_comment_ids,
          fn {id, remaining} -> id == response_id end)

        # find the index of the user_idea
        i = Enum.find_index(r_ids, fn x -> x == response_id end)

        # find the idea_id and time since user idea has been posted
        case Enum.at(socket.assigns.user_idea_ids, i) do
          {idea_id, passed } ->
            { response_id, idea_id, passed + remaining }
          nil -> { response_id, nil, nil}
        end
      end)
    |> Enum.filter(fn {_, idea_id, remaining} -> not is_nil(idea_id) end)

    bot_to_user_comments ++ []
    |> Enum.map(fn {c, i, r } -> [c, i, r] end)
  end

  # defp schedule_comment(socket, comment) do
  #   if comment.remaining > 0 do
  #     spawn(fn -> :timer.sleep(comment.remaining * 1000);
  #       push socket, "post_comment", %{
  #         idea_id: comment.idea_id,
  #         comment: render_to_string(CommentView, "comment.html",
  #           comment: comment,
  #           user: socket.assigns.user
  #         )
  #       }
  #     end)
  #   else
  #     push socket, "post_comment", %{
  #       idea_id: comment.idea_id,
  #       comment: render_to_string(CommentView, "comment.html",
  #         comment: comment,
  #         user: socket.assigns.user
  #       )
  #     }
  #   end
  # end

#   defp schedule_first_response_comment(socket, idea_id) do
#     delay = NaiveDateTime.diff NaiveDateTime.utc_now(),
#       socket.assigns.user.inserted_at

#     comment = case socket.assigns.user.condition do
#       3 -> load_comment(24, socket.assigns.user, delay)
#       4 -> load_comment(26, socket.assigns.user, delay)
#       7 -> load_comment(28, socket.assigns.user, delay)
#       8 -> load_comment(33, socket.assigns.user, delay)
#     end
#     IO.inspect comment
#     schedule_comment socket, Map.put(comment, :idea_id, idea_id)
#   end

#   defp schedule_second_response_comment(socket, idea_id) do
#     delay = NaiveDateTime.diff NaiveDateTime.utc_now(),
#       socket.assigns.user.inserted_at

#     comment = case socket.assigns.user.condition do
#       7 -> load_comment(29, socket.assigns.user, delay)
#       8 -> load_comment(34, socket.assigns.user, delay)
#     end

#     IO.inspect comment

#     schedule_comment socket, Map.put(comment, :idea_id, idea_id)
#   end

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
