defmodule Collaboration.AdminChannel do
  use Collaboration.Web, :channel

  # alias Collaboration.Comment
  alias Collaboration.Data
  alias Collaboration.Endpoint
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

  def handle_in("toggle", %{"id"=>id, "table"=>table, "field"=>field}, socket) do

    entry = case table do
      "topic" -> Repo.get!(Topic, id)
      "user" -> Repo.get!(User, id)
    end

    field = String.to_atom(field)
    value = Map.fetch!(entry, field)
    entry = Ecto.Changeset.change entry, %{field => !value}

    case Repo.update entry do
      {:ok, res}       -> # Updated with success

        # update admin window
        broadcast! socket, "toggle", %{ id: id, table: table, field: field }

        # update menulist
        if table == "topic" && field == :hidden do

          data = %{
            id: res.id,
            order: res.order,
            menutitle: res.menutitle,
          }

          case res.hidden do
            false -> Endpoint.broadcast!("public", "menutopic-show", data)
            true ->  Endpoint.broadcast!("public", "menutopic-hide", data)
          end
        end

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