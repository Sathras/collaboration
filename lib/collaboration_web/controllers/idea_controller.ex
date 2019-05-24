defmodule CollaborationWeb.IdeaController do
  use CollaborationWeb, :controller

  import Collaboration.Contributions

  alias Collaboration.Contributions.{Comment,Rating}

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
            rating_changeset: change_rating(%Rating{}),
            ideas: load_past_ideas(topic.id, user),
            topic: topic
          )
    end
  end

  def rate(conn, %{"rating" => rating_params}) do
    user = current_user(conn)

    case rate_idea(user, rating_params) do
      {:ok, _rating} ->
        redirect conn, to: Routes.topic_path(conn, :show)

      {:error, _changeset} ->
        conn
        |> put_flash(:error, "An error occurred while rating this idea.")
        |> redirect to: Routes.topic_path(conn, :show)
    end
  end

  def unrate(conn, %{"idea_id" => idea_id}) do
    case unrate_idea(current_user(conn), idea_id) do
      {:ok, _rating} ->
        redirect conn, to: Routes.topic_path(conn, :show)

      {:error, _changeset} ->
        conn
        |> put_flash(:error, "An error occurred while removing the rating for this idea.")
        |> redirect to: Routes.topic_path(conn, :show)
    end
  end
end
