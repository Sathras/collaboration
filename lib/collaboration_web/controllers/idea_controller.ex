defmodule CollaborationWeb.IdeaController do
  use CollaborationWeb, :controller

  import Collaboration.Contributions

  alias Collaboration.Contributions.Comment

  def create(conn, %{"idea" => idea_params}) do

    topic = get_published_topic()
    user = current_user(conn)

    case create_idea(user, topic, idea_params) do
      {:ok, _idea} ->
        redirect conn, to: Routes.topic_path(conn, :show)

      {:error, changeset} ->
        conn
        |> put_view(CollaborationWeb.TopicView)
        |> render( "show.html",
            comment_changeset: nil,
            idea_changeset: changeset,
            ideas: load_past_ideas(topic.id, user),
            topic: topic
          )
    end
  end
end
