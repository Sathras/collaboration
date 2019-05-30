defmodule CollaborationWeb.TopicController do
  use CollaborationWeb, :controller

  import Collaboration.Contributions

  alias Collaboration.Contributions.{Topic, Idea, Rating}

  @minTime Application.fetch_env!(:collaboration, :minTime)

  @doc """
  Function plug that adds the currently published topic to the conn or displays a flash error.
  """
  def add_topic(conn, _opts) do
    case get_published_topic() do
      nil ->
        conn
        |> assign(:topic, nil)
        |> put_flash(:error, "Experiment participation is currently disabled.")
      topic ->
        assign(conn, :topic, topic)
    end
  end

  # # controller serves as plug to add published topic to conn.assigns
  # def init(opts), do: opts

  # def call(conn, _opts) do
  #   conn

  # end
  # # End: Plug code

  def index(conn, _) do
    render conn, "index.html", topics: list_topics()
  end

  def show(conn, _) do
    conn
    |> prepare_topic()
    |> render("show.html")
  end

  def new(conn, _), do: render(conn, "new.html", changeset: change_topic(%Topic{}))

  def edit(conn, %{"id" => id}) do
    topic = get_topic!(id)
    render(conn, "edit.html", changeset: change_topic(topic), topic: topic)
  end

  def feature(conn, %{"id" => id}) do
    case feature_topic(id) do
      {:ok, _topic} ->
        redirect(conn, to: Routes.topic_path(conn, :index))
      {:error, _changeset} ->
        conn
        |> put_flash(:info, "Topic cannot be featured.")
        |> redirect(to: Routes.topic_path(conn, :index))
    end
  end

  def create(conn, %{"topic" => params}) do
    case create_topic(params) do
      {:ok, _topic} ->
        conn
        |> put_flash(:info, "Topic created successfully.")
        |> redirect(to: Routes.topic_path(conn, :index))

      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def update(conn, %{"id" => id, "topic" => params}) do
    case update_topic(get_topic!(id), params) do
      {:ok, _topic} ->
        conn
        |> put_flash(:info, "Topic updated successfully.")
        |> redirect(to: Routes.topic_path(conn, :index))

      {:error, changeset} ->
        render(conn, "edit.html", changeset: changeset)
    end
  end

  def prepare_topic(conn) do

    topic = current_topic(conn)
    user = current_user(conn)
    reload_in = max(0, - NaiveDateTime.diff(
      NaiveDateTime.utc_now(),
      NaiveDateTime.add(user.inserted_at, @minTime),
      :milliseconds
    ))

    merge_assigns(conn,
      topic: topic,
      comment_changeset: nil,
      idea_changeset: change_idea(%Idea{}),
      rating_changeset: change_rating(%Rating{}),
      reload_in: reload_in,
      ideas: load_past_ideas(topic.id, current_user(conn))
    )
  end
end
