defmodule CollaborationWeb.IdeaController do
  use CollaborationWeb, :controller
  # alias CollaborationWeb.Endpoint
  # alias CollaborationWeb.CommentView
  # import Phoenix.View, only: [render_to_string: 3]

  def create(conn, %{"idea" => params}) do
    topic = get_published_topic!()
    # user = get_user!(conn.assigns.current_user.id)
    user = current_user(conn)
    case create_idea(user, topic, params) do
      {:ok, _idea} ->
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

        conn
        |> put_flash(:info, "Idea created successfully.")
        |> redirect(to: Routes.topic_path(conn, :show))

      {:error, changeset} ->
        ideas = load_ideas(topic.id, user)
        conn
        |> put_view(CollaborationWeb.TopicView)
        |> render(:show,
            idea_changeset: changeset,
            comment_changeset: comment_changeset(),
            ideas: ideas,
            user_ideas: user_ideas(ideas, user.id),
            topic: topic)
    end
  end
end
