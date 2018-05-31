defmodule CollaborationWeb.TopicController do
  use CollaborationWeb, :controller

  import Collaboration.Contributions
  import CollaborationWeb.ViewHelpers, only: [admin?: 1]

  def index(conn, _) do
    render conn, "index.html", topics: list_topics(admin?(conn))
    # topics = list_topics(admin?(conn))
    # render(assign(conn, :topics, topics), "index.html")
  end

  def show(conn, %{"id" => id} = params) do
    current_user = Coherence.current_user(conn)
    topic = get_topic!(id)
    ideas = list_ideas(topic.id, current_user)
    current_idea = Map.get(params, "idea", nil)
    render conn, "show.html",
      current_idea: Enum.find(ideas, fn(x) -> x.id == current_idea end),
      current_user: current_user,
      topic: topic,
      ideas: ideas,
      my_ratings: list_my_ratings(Enum.map(ideas, & &1.id), current_user)
  end

  def new(conn, _), do: render(conn, "new.html", changeset: change_topic())

  def edit(conn, %{"id" => id}) do
    topic = get_topic!(id)
    render(conn, "edit.html", changeset: change_topic(topic), topic: topic)
  end

  def create(conn, %{"topic" => params}) do
    case create_topic(params) do
      {:ok, topic} ->
        conn
        |> put_flash(:info, "Topic created successfully.")
        |> redirect(to: topic_path(conn, :show, topic))

      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def update(conn, %{"id" => id, "topic" => params}) do
    case update_topic(get_topic!(id), params) do
      {:ok, topic} ->
        conn
        |> put_flash(:info, "Topic updated successfully.")
        |> redirect(to: topic_path(conn, :show, topic))

      {:error, changeset} ->
        render(conn, "edit.html", changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    get_topic!(id) |> delete_topic

    conn
    |> put_flash(:info, "Topic deleted successfully.")
    |> redirect(to: topic_path(conn, :index))
  end
end
