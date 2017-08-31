defmodule Collaboration.AdminChannel do
  use Collaboration.Web, :channel

  # alias Collaboration.Comment
  alias Collaboration.Data
  # alias Collaboration.Idea
  alias Collaboration.Topic
  alias Collaboration.TopicView
  alias Collaboration.User
  alias Collaboration.UserView
  alias Phoenix.View

  def join("admin", _params, socket) do
    case socket.assigns.admin do
      true ->
        # get and format all topics and users
        resp = %{
          topics: View.render_many(Repo.all(Topic), TopicView, "topic-admin.json"),
          users: View.render_many(Repo.all(User), UserView, "user-admin.json")
        }
        {:ok, resp, socket}

      false -> {:error, socket}
    end
  end

  def handle_in("toggle", %{"id" => id, "table" => table, "field" => field,
    "value" => value }, socket) do

    entry = case table do
      "topic" -> Repo.get!(Topic, id)
      "user" -> Repo.get!(User, id)
    end

    entry = Ecto.Changeset.change entry, %{String.to_atom(field) => !value}

    case Repo.update entry do
      {:ok, _entry}       -> # Updated with success
        broadcast! socket, "toggle", %{ id: id, table: table, field: field }
        {:noreply, socket}
      {:error, _changeset} -> # Something went wrong
        {:noreply, socket}
    end
  end

  def handle_in("update-data", %{"field" => field, "value" => value}, socket) do

    changeset = Data.changeset(
      Repo.get_by!(Data, field: field),
      %{value: value}
    )

    case Repo.update changeset do
      {:ok, _entry}       -> # Updated with success
        broadcast! socket, "update-data", %{ field: field, value: value }
        {:noreply, socket}
      {:error, _changeset} -> # Something went wrong
        {:noreply, socket}
    end

    IO.inspect changeset
    {:noreply, socket}
  end
end