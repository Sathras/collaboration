defmodule CollaborationWeb.IdeaController do
  use CollaborationWeb, :controller
  alias CollaborationWeb.Endpoint
  alias CollaborationWeb.CommentView
  import Phoenix.View, only: [render_to_string: 3]

  def index(conn, %{"topic_id" => topic_id}) do
    if current_user(conn) do
      redirect conn, to: topic_idea_path(conn, :new, topic_id )
    else
      render conn, "index.html",
        ideas: load_ideas(topic_id, current_user(conn)),
        topic: get_topic!(topic_id)
    end
  end

  def new(conn, %{"topic_id" => topic_id} = params) do
    render conn, "index.html",
      changeset: Map.get(params, :changeset, change_idea()),
      ideas: load_ideas(topic_id, current_user(conn)),
      topic: get_topic!(topic_id)
  end

  def create(conn, %{"topic_id" => topic_id, "idea" => params}) do
    topic = get_topic!(topic_id)
    user = current_user conn
    case create_idea(user, topic, params) do
      {:ok, idea} ->
        # create automated feedback (if not admin or in condition 1 and 2
        if !user.admin && user.condition in [3,4] do
          Task.Supervisor.async_nolink(Collaboration.TaskSupervisor, fn ->
            # wait for a little amount of time
            :timer.sleep Enum.random(5000..10000)
            # then create an automated feedback
            sequence = user.feedback_sequence
            feedback = case sequence do
              0 -> "1. Automated Feedback"
              1 -> "2. Automated Feedback"
              2 -> "3. Automated Feedback"
              3 -> "4. Automated Feedback"
              4 -> "5. Automated Feedback"
              5 -> "6. Automated Feedback"
              6 -> "7. Automated Feedback"
              7 -> "8. Automated Feedback"
              8 -> "9. Automated Feedback"
              9 -> "10. Automated Feedback"
            end
            # create automated feedback
            random_user = select_random_user(user.condition, user.id)
            case create_comment(random_user, user, idea, %{text: feedback}) do
              {:ok, comment} ->
                # broadcast back to user
                Endpoint.broadcast("user:" <> user.id, "new_feedback", %{
                  idea_id: idea.id,
                  comment: render_to_string(CommentView, "comment.html",
                    admin: user.admin,
                    comment: load_comment(comment.id, user),
                    user_id: user.id
                  )
                })
            end
            # increase_feedback_sequence user
            sequence = if sequence === 9, do: 0, else: sequence + 1
            update_user(user, %{feedback_sequence: sequence})
          end)
        end

        conn
        |> put_flash(:info, "Idea created successfully.")
        |> redirect(to: topic_path(conn, :show, topic_id ))

      {:error, changeset} ->
        conn
        |> put_flash(:error, "Please check your errors!")
        |> redirect(to: "/topics/#{topic_id}", changeset: changeset)
    end
  end

  def edit(conn, %{"id" => id, "topic_id" => topic_id} = params) do
    render conn, "index.html",
      id: topic_id,
      changeset: Map.get(params, :changeset, change_idea(get_idea!(id))),
      ideas: load_ideas(topic_id, current_user(conn)),
      topic: get_topic!(topic_id)
  end

  def update(conn, %{"id" => id, "topic_id" => topic_id, "idea" => params}) do
    case update_idea(get_idea!(id), params) do
      {:ok, idea} ->
        conn
        |> redirect(to: topic_idea_path(conn, :show, topic_id, idea.id ))

      {:error, changeset} ->
        render conn, "index.html",
          changeset: changeset,
          ideas: load_ideas(topic_id, current_user(conn)),
          topic: get_topic!(topic_id)
    end
  end

  def delete(conn, %{"id" => id, "topic_id" => topic_id}) do
    delete_idea(id)
    redirect conn, to: topic_path(conn, :show, topic_id )
  end
end
