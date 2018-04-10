defmodule CollaborationWeb.IdeaController do
  use CollaborationWeb, :controller

  import Collaboration.Contributions
  alias Collaboration.Contributions.Idea

  def index(conn, %{"topic_id" => id}) do
    topic = get_topic!(id)
    render conn, "index.html",
      topic: topic,
      ideas: list_ideas(topic.id),
      idea: nil,
      idea_changeset: change_idea()
  end

  def show(conn, %{"topic_id" => topic_id, "id" => id}) do
    topic = get_topic!(topic_id)
    idea =  get_idea!(id, :preload_comments)
    user_rating = if Coherence.current_user(conn),
      do: get_user_rating!(conn.assigns.current_user, idea),
      else: nil

    render conn, "index.html",
      topic: topic,
      ideas: list_ideas(topic.id),
      idea: idea,
      idea_changeset: change_idea(),
      edit_idea_changeset: change_idea(idea),
      rating: Map.put(get_ratings!(idea), :user, user_rating)
  end

  def create(conn, %{"topic_id" => topic_id, "idea" => params}) do
    topic = get_topic! topic_id
    case create_idea(conn.assigns[:current_user], topic, params) do
      {:ok, idea} ->
        conn
        |> put_flash(:info, "Idea created successfully.")
        |> redirect(to: topic_idea_path(conn, :show, topic, idea))
      {:error, changeset} ->
        render conn, "index.html",
          topic: topic,
          ideas: list_ideas(topic.id),
          idea: nil,
          idea_changeset: changeset,
          edit_idea_changeset: change_idea()
    end
  end

  def update(conn, %{"topic_id" => topic_id, "id" => id, "idea" => params}) do
    idea = get_idea!(id)
    case update_idea(idea, params) do
      {:ok, idea} ->
        IO.inspect idea
        conn
        |> put_flash(:info, "Idea updated successfully.")
        |> redirect(to: topic_idea_path(conn, :show, topic_id, idea))
      {:error, changeset} ->
        topic = get_topic! topic_id
        render conn, "index.html",
          topic: topic,
          ideas: list_ideas(topic.id),
          idea: idea,
          idea_changeset: change_idea(%Idea{}),
          edit_idea_changeset: changeset
    end
  end

  def delete(conn, %{"topic_id" => topic_id, "id" => id}) do
    get_idea!(id) |> delete_idea
    conn
    |> put_flash(:info, "Idea deleted successfully.")
    |> redirect(to: topic_idea_path(conn, :index, topic_id))
  end
end