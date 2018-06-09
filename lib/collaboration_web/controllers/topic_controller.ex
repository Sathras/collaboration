defmodule CollaborationWeb.TopicController do
  use CollaborationWeb, :controller

  import CollaborationWeb.ViewHelpers, only: [admin?: 1]

  def home(conn, _) do
    if current_user(conn), do: redirect(conn, to: topic_path(conn, :index)),
    else: redirect(conn, to: user_path(conn, :start))
  end

  def index(conn, _) do
    render conn, "index.html", topics: list_topics(admin?(conn))
  end

  def show(conn, %{"id" => id} = params) do
    IO.inspect conn.assigns
    render conn, "show.html",
      changeset: Map.get(params, :idea_changeset, change_idea()),
      ideas: load_ideas(id, current_user(conn)),
      topic: get_topic!(id)
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
end
