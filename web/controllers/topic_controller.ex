defmodule Collaboration.TopicController do
  use Collaboration.Web, :controller

  plug :auth_admin when action in [:new, :create, :edit, :update, :delete]

  import Collaboration.UserView, only: [displayName: 1]

  alias Collaboration.Comment
  alias Collaboration.Idea
  alias Collaboration.Topic
  alias Collaboration.User
  alias Collaboration.UserView

  def index(conn, _params) do
    topics = Repo.all(Topic)
    render(conn, "index.html", topics: topics)
  end

  def new(conn, _params) do
    changeset = Topic.changeset(%Topic{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"topic" => topic_params}) do
    changeset = Topic.changeset(%Topic{}, topic_params)

    case Repo.insert(changeset) do
      {:ok, _topic} ->
        conn
        |> put_flash(:info, "Topic created successfully.")
        |> redirect(to: topic_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do

    user = conn.assigns.current_user
    topic = Repo.get!(Topic, id)

    # if admin, provide a list of fauxusers that user can use to post idea/comment
    fauxusers = if user && user.admin do
      Phoenix.View.render_many(Repo.all(
        from u in User,
          select: %{
            id: u.id,
            firstname: u.firstname,
            lastname: u.lastname,
            username: u.username
          },
          where: u.id == ^user.id,
          or_where: u.faux
        ),
        UserView, "user-name.json"
      )
    else nil end

    em = if (user && !topic.closed)||(user && user.admin), do: true, else: false

    render conn, "show.html", topic: topic, fauxusers: fauxusers, editMode: em
  end

  def edit(conn, %{"id" => id}) do
    topic = Repo.get!(Topic, id)
    changeset = Topic.changeset(topic)
    render(conn, "edit.html", topic: topic, changeset: changeset)
  end

  def update(conn, %{"id" => id, "topic" => topic_params}) do
    topic = Repo.get!(Topic, id)
    changeset = Topic.changeset(topic, topic_params)
    case Repo.update(changeset) do
      {:ok, topic} ->
        conn
        |> put_flash(:info, "Topic updated successfully.")
        |> redirect(to: topic_path(conn, :show, topic))
      {:error, changeset} ->
        render(conn, "edit.html", topic: topic, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    topic = Repo.get!(Topic, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(topic)

    conn
    |> put_flash(:info, "Topic deleted successfully.")
    |> redirect(to: topic_path(conn, :index))
  end
end
