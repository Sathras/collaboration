defmodule Collaboration.TopicChannel do
  use Collaboration.Web, :channel

  alias Collaboration.Idea
  alias Collaboration.Topic
  alias Collaboration.User

  def join("topic:" <> topic_id, _params, socket) do

    if !String.to_integer(topic_id), do:
      {:error, socket},
    else:
      {:ok, assign(socket, :topic_id, String.to_integer(topic_id))}
  end

  def handle_in(event, params, socket) do
    user_id = if socket.assigns.admin && params["user_id"],
      do: params["user_id"],
      else: socket.assigns.user_id
    user = Repo.get(User, user_id)

    handle_in(event, params, user, socket)
  end

  def handle_in("new_idea", params, user, socket) do

    changeset = Idea.changeset(
      %Idea{user_id: user.id, topic_id: socket.assigns.topic_id},
      params
    )

    case Repo.insert(changeset) do
      {:ok, idea} ->
        broadcast! socket, "new_idea", %{
          title: params["title"],
          description: params["description"],
          user: user.id
        }
        {:reply, :ok, socket}

      {:error, changeset} ->
        {:reply, {:error, %{errors: changeset}}, socket}
    end
  end

end