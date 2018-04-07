defmodule CollaborationWeb.TopicController do
  use CollaborationWeb, :controller

  alias Collaboration.Contributions
  alias Collaboration.Contributions.Idea
  alias Collaboration.Contributions.Topic

  def index(conn, _params) do
    topics = Contributions.list_topics()
    render(conn, "index.html", topics: topics)
  end

  def new(conn, _params) do
    changeset = Contributions.change_topic(%Topic{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"topic" => topic_params}) do
    case Contributions.create_topic(topic_params) do
      {:ok, topic} ->
        conn
        |> put_flash(:info, "Topic created successfully.")
        |> redirect(to: topic_path(conn, :show, topic))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id} = params) do
    IO.inspect params
    topic = Contributions.get_topic_via_slug!(id)
    idea_changeset = Contributions.change_idea(%Idea{})
    render(conn, "show.html", topic: topic, idea_changeset: idea_changeset)
  end

  def edit(conn, %{"id" => id}) do
    topic = Contributions.get_topic_via_slug!(id)
    changeset = Contributions.change_topic(topic)
    render(conn, "edit.html", topic: topic, changeset: changeset)
  end

  def update(conn, %{"id" => id, "topic" => topic_params}) do
    topic = Contributions.get_topic!(id)

    case Contributions.update_topic(topic, topic_params) do
      {:ok, topic} ->
        conn
        |> put_flash(:info, "Topic updated successfully.")
        |> redirect(to: topic_path(conn, :show, topic.slug))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", topic: topic.slug, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    topic = Contributions.get_topic!(id)
    {:ok, _topic} = Contributions.delete_topic(topic)

    conn
    |> put_flash(:info, "Topic deleted successfully.")
    |> redirect(to: topic_path(conn, :index))
  end

  def add_idea(conn, %{"slug" => slug, "idea" => idea_params}) do
    topic = Contributions.get_topic_via_slug! slug
    user = conn.assigns[:current_user]
    case Contributions.create_idea(user, topic, idea_params) do
      {:ok, _idea} ->
        conn
        |> put_flash(:info, "Idea created successfully.")
        |> redirect(to: topic_path(conn, :show, slug))
      {:error, %Ecto.Changeset{} = changeset} ->
        render conn, "show.html", topic: topic, idea_changeset: changeset
    end
  end
end
