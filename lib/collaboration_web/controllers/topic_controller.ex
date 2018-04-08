defmodule CollaborationWeb.TopicController do
  use CollaborationWeb, :controller

  import Collaboration.Contributions

  def index(conn, _), do: render conn, "index.html"

  def new(conn, _), do: render conn, "new.html", changeset: change_topic()

  def edit(conn, %{"slug" => s}), do:
    render conn, "edit.html", changeset: get_topic_via_slug!(s) |> change_topic

  def create(conn, %{"topic" => params}) do
    case create_topic(params) do
      {:ok, topic} ->
        conn
        |> put_flash(:info, "Topic created successfully.")
        |> redirect(to: topic_idea_path(conn, :index, topic.slug))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def update(conn, %{"slug" => s, "topic" => params}) do
    case update_topic(get_topic_via_slug!(s), params) do
      {:ok, _topic} ->
        conn
        |> put_flash(:info, "Topic updated successfully.")
        |> redirect(to: topic_idea_path(conn, :index, s))
      {:error, changeset} ->
        render conn, "edit.html", changeset: changeset
    end
  end

  def delete(conn, %{ "slug" => s }) do
    get_topic_via_slug!(s) |> delete_topic
    conn
    |> put_flash(:info, "Topic deleted successfully.")
    |> redirect(to: topic_path(conn, :index))
  end
end
