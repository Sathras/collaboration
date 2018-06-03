defmodule CollaborationWeb.IdeaController do
  use CollaborationWeb, :controller

  def index(conn, %{"topic_id" => topic_id}) do
    if current_user(conn) do
      redirect conn, to: topic_idea_path(conn, :new, topic_id )
    else
      render conn, "index.html",
        ideas: load_ideas(topic_id, current_user(conn)),
        topic: get_topic!(topic_id)
    end
  end

  def show(conn, %{"id" => id, "topic_id" => topic_id}) do
    render conn, "index.html",
      comments: load_comments(id, current_user(conn)),
      idea: load_idea(id, current_user(conn)),
      ideas: load_ideas(topic_id, current_user(conn)),
      topic: get_topic!(topic_id)
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
        conn
        |> put_flash(:info, "Idea created successfully.")
        |> redirect(to: topic_idea_path(conn, :show, topic_id, idea.id ))

      {:error, changeset} ->
        render conn, "index.html",
          changeset: changeset,
          ideas: load_ideas(topic_id, current_user(conn)),
          topic: get_topic!(topic_id)
    end
  end

  def edit(conn, %{"id" => id, "topic_id" => topic_id} = params) do
    render conn, "index.html",
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
    redirect(conn, to: topic_idea_path(conn, :index, topic_id ))
  end
end
