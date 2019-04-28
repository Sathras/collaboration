defmodule CollaborationWeb.TopicController do
  use CollaborationWeb, :controller

  import Collaboration.Contributions

  def index(conn, _) do
    render conn, "index.html", topics: list_topics()
  end

  def show(conn, _) do
    user = current_user(conn)

    cond do
      # admin users should be redirected to admin page.
      user && not is_nil(user.credential) ->
        redirect(conn, to: Routes.download_path(conn, :index))

      # normal users should see the experiment.
      user ->
        case get_published_topic() do
          nil ->
            conn
            |> send_resp(404, "No topic is currently published.")
            |> halt()

          topic ->
            render conn, "show.html",
              ideas: load_past_ideas(topic.id, current_user(conn)),
              topic: topic
        end

        # anonymous users should be redirected to experiment start page.
      true ->
        redirect conn, to: Routes.user_path(conn, :new)
    end
  end

  def new(conn, _), do: render(conn, "new.html", changeset: change_topic())

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
end
