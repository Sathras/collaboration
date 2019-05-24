defmodule CollaborationWeb.CommentController do
  use CollaborationWeb, :controller

  import Collaboration.Contributions

  alias Collaboration.Contributions.{Comment, Idea, Rating}

  def create(conn, %{"comment" => comment_params}) do

    user = current_user(conn)

    case create_comment(user, comment_params) do


      {:ok, _comment} ->
        redirect conn, to: Routes.topic_path(conn, :show)

      {:error, changeset} ->

        topic = get_published_topic()

        conn
        |> put_view(CollaborationWeb.TopicView)
        |> render( "show.html",
            comment_changeset: changeset,
            idea_changeset: change_idea(%Idea{}),
            rating_changeset: change_rating(%Rating{}),
            ideas: load_past_ideas(topic.id, user),
            topic: topic
          )
    end
  end

  def toggle_like(conn, %{"id" => comment_id}) do
    toggle_like_comment(comment_id, current_user(conn).id)
    redirect conn, to: Routes.topic_path(conn, :show)
  end
end
