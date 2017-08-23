defmodule Collaboration.TopicController do
  use Collaboration.Web, :controller

  plug :auth_admin when action in [:new, :create, :edit, :update, :delete]

  alias Collaboration.Comment
  alias Collaboration.Idea
  alias Collaboration.Topic
  alias Collaboration.User

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
    fauxusers = if user && user.admin, do:
      Repo.all(
        from u in User,
        select: %{id: u.id, firstname: u.firstname, lastname: u.lastname},
        where: u.id == ^user.id,
        or_where: u.faux
      ),
    else: nil

    comments_query = from c in Comment, order_by: c.inserted_at, preload: :user

    ideas = cond do
      user && user.admin ->
        Repo.all(
          from i in Idea,
          where: i.topic_id == ^id,
          preload: [:user, comments: ^comments_query],
          order_by: [desc: i.inserted_at]
        )
      user ->
        Repo.all(
          from i in Idea,
          join: u in assoc(i, :user),
          where: i.topic_id == ^id,
          where: u.faux == true,
          or_where: i.user_id == ^user.id,
          preload: [:user, comments: ^comments_query],
          order_by: [desc: i.inserted_at]
        )
      true ->
        Repo.all(
          from i in Idea,
          join: u in assoc(i, :user),
          where: i.topic_id == ^id,
          where: u.faux == true,
          preload: [:user, comments: ^comments_query],
          order_by: [desc: i.inserted_at]
        )
    end

    idea_changeset = Idea.changeset(%Idea{})

    render(conn, "show.html",
      topic: topic,
      fauxusers: fauxusers,
      ideas: ideas,
      idea_changeset: idea_changeset
    )
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
