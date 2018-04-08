defmodule CollaborationWeb.IdeaController do
  use CollaborationWeb, :controller

  import Collaboration.Contributions
  alias Collaboration.Contributions.Idea

  def index(conn, %{"topic_slug" => s}) do
    topic = get_topic_via_slug!(s)
    render conn, "index.html",
      topic: topic,
      ideas: list_ideas(topic.id),
      idea: nil,
      idea_changeset: change_idea()
  end

  def show(conn, %{"topic_slug" => s, "id" => id}) do
    topic = get_topic_via_slug!(s)
    idea =  get_idea!(id)
    render conn, "index.html",
      topic: topic,
      ideas: list_ideas(topic.id),
      idea: idea,
      idea_changeset: change_idea(),
      edit_idea_changeset: change_idea(idea)
  end

  def create(conn, %{"topic_slug" => s, "idea" => params}) do
    topic = get_topic_via_slug! s
    case create_idea(conn.assigns[:current_user], topic, params) do
      {:ok, idea} ->
        conn
        |> put_flash(:info, "Idea created successfully.")
        |> redirect(to: topic_idea_path(conn, :show, s, idea.id))
      {:error, changeset} ->
        render conn, "index.html",
          topic: topic,
          ideas: list_ideas(topic.id),
          idea: nil,
          idea_changeset: changeset,
          edit_idea_changeset: change_idea()
    end
  end

  def update(conn, %{"topic_slug" => s, "id" => id, "idea" => params}) do
    idea = get_idea!(id)
    case update_idea(idea, params) do
      {:ok, idea} ->
        conn
        |> put_flash(:info, "Idea updated successfully.")
        |> redirect(to: topic_idea_path(conn, :show, s, idea))
      {:error, changeset} ->
        topic = get_topic_via_slug! s
        render conn, "index.html",
          topic: topic,
          ideas: list_ideas(topic.id),
          idea: idea,
          idea_changeset: change_idea(%Idea{}),
          edit_idea_changeset: changeset
    end
  end

  def delete(conn, %{"topic_slug" => s, "id" => id}) do
    get_idea!(id) |> delete_idea
    conn
    |> put_flash(:info, "Idea deleted successfully.")
    |> redirect(to: topic_idea_path(conn, :index, s))
  end
end