defmodule CollaborationWeb.TopicController do
  use CollaborationWeb, :controller

  import Collaboration.Contributions

  def index(conn, _), do: render conn, "index.html"

  def new(conn, _), do: render conn, "new.html", changeset: change_topic()

  def edit(conn, %{"id" => id}) do
    topic = get_topic!(id)
    render conn, "edit.html", changeset: change_topic(topic), topic: topic
  end

  def create(conn, %{"topic" => params}) do
    case create_topic(params) do
      {:ok, topic} ->
        conn
        |> put_flash(:info, "Topic created successfully.")
        |> redirect(to: topic_idea_path(conn, :index, topic))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def update(conn, %{"id" => id, "topic" => params}) do
    case update_topic(get_topic!(id), params) do
      {:ok, topic} ->
        conn
        |> put_flash(:info, "Topic updated successfully.")
        |> redirect(to: topic_idea_path(conn, :index, topic))
      {:error, changeset} ->
        render conn, "edit.html", changeset: changeset
    end
  end

  def delete(conn, %{ "id" => id }) do
    get_topic!(id) |> delete_topic
    conn
    |> put_flash(:info, "Topic deleted successfully.")
    |> redirect(to: topic_path(conn, :index))
  end
end
