defmodule Collaboration.TopicChannel do
  use Collaboration.Web, :channel

  alias Collaboration.Comment
  alias Collaboration.Idea
  alias Collaboration.IdeaView
  alias Collaboration.User
  alias Phoenix.View

  def join("topic:" <> topic_id, _params, socket) do

    topic_id = String.to_integer(topic_id)

    comments_query = from c in Comment, order_by: c.inserted_at, preload: :user

    ideas = cond do
      socket.assigns.admin ->
        Repo.all(
          from i in Idea,
          where: i.topic_id == ^topic_id,
          preload: [:user, comments: ^comments_query],
          order_by: [desc: i.inserted_at]
        )
      socket.assigns.user_id ->
        Repo.all(
          from i in Idea,
          join: u in assoc(i, :user),
          where: i.topic_id == ^topic_id,
          where: u.faux == true,
          or_where: i.user_id == ^socket.assigns.user_id,
          preload: [:user, comments: ^comments_query],
          order_by: [desc: i.inserted_at]
        )
      true ->
        Repo.all(
          from i in Idea,
          join: u in assoc(i, :user),
          where: i.topic_id == ^topic_id,
          where: u.faux == true,
          preload: [:user, comments: ^comments_query],
          order_by: [desc: i.inserted_at]
        )
    end

    resp = %{ideas: Phoenix.View.render_many(ideas, Collaboration.IdeaView, "idea.json")}

    {:ok, resp, assign(socket, :topic_id, topic_id)}
  end

  def handle_in(event, params, socket) do
    user_id = if socket.assigns.admin && params["user_id"],
      do: params["user_id"],
      else: socket.assigns.user_id
    user = Repo.get(User, user_id)

    handle_in(event, params, user, socket)
  end

  # submitting a new or updated idea
  def handle_in("submit-idea", params, user, socket) do

    # get existing post if it exists, otherwise create a new structure
    result =
      case params["idea_id"] do
        nil ->  %Idea{user_id: user.id, topic_id: socket.assigns.topic_id}
        id  ->  case Repo.get!(Idea, id) do
                  nil  -> %Idea{user_id: user.id, topic_id: socket.assigns.topic_id}
                  idea -> idea
                end
      end
      |> Idea.changeset(params)   # validate input params
      |> Repo.insert_or_update    # insert or update it in database

    case result do
      {:ok, idea}       -> # Inserted or updated with success
        # load comments and user
        idea = Repo.preload idea, [:comments, :user]
        {:reply, {:ok, View.render_one(idea, IdeaView, "idea.json")}, socket}
      {:error, changeset} -> # Something went wrong
        errors = error_socket(changeset)
        {:reply, {:error, %{errors: errors}}, socket}
    end
  end


  # submitting a new or updated idea
  def handle_in("delete-idea", %{"idea" => i}, user, socket) do

    if !user.admin do
      {:reply, :error, socket}
    else
      idea = Repo.get!(Idea, i)
      case Repo.delete idea do
        {:ok, _struct}       -> # Deleted with success
          {:reply, :ok, socket}
        {:error, _changeset} -> # Something went wrong
          {:reply, :error, socket}
      end
    end
  end

  def handle_in("new_comment", params, user, socket) do

    changeset = Comment.changeset(
      %Comment{user_id: user.id, idea_id: String.to_integer(params["idea_id"])},
      params
    )

    case Repo.insert(changeset) do
      {:ok, comment} ->
        broadcast! socket, "new_comment", %{
          text: comment.text,
          idea: comment.id,
          user: user.id
        }
        {:reply, :ok, socket}

      {:error, changeset} ->
        {:reply, {:error, %{errors: changeset}}, socket}
    end
  end

end