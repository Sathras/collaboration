defmodule CollaborationWeb.TopicChannel do
  use CollaborationWeb, :channel

  alias Phoenix.View
  alias CollaborationWeb.{ IdeaView, CommentView }

  def join("topic", _params, socket) do
    t = topic_id(socket)
    u = user(socket)

    # load bot-to-user comments and user_ideas (id and inserted_at)
    socket = socket
    |> assign(:bot_to_user_comments, get_bot_to_user_comments(u))
    |> assign(:user_idea_ids, get_user_idea_ids(t, u))
    |> assign(:user_comment_ids, get_user_comment_ids(u))

    {:ok, %{
      ideas: load_future_ideas(t, u),
      comments: get_comment_schedule(socket)
    }, socket}
  end

  def handle_in("create_idea", %{ "text" => text }, socket) do
    u = user(socket)
    case create_idea(text, topic_id(socket), u) do
      { :ok, idea } ->

        # add idea_id to idea_ids in socket
        ids = user_idea_ids(socket)
        socket = assign socket, :user_idea_ids, ids ++ [idea.id]

        # determine if a response comment should be prepared
        f = case Enum.at(idea_response_ids(u.condition), Enum.count(ids)) do
          nil -> nil
          rid ->
            case get_bot_comment(socket, rid, idea.inserted_at) do
              nil -> nil
              c -> [ idea.id, c.delay, render_comment(c, u) ]
            end
        end

        # prepare idea for socket
        idea = idea
        |> View.render_one(IdeaView, "idea.json", user: u )
        |> render_idea(u)

        {:reply, {:ok, %{ idea: idea, feedback: f }}, socket}

      {:error, _changeset } ->
        {:reply, :error, socket}
    end
  end

  def handle_in("create_comment", params, socket) do
    params = Map.put params, "user_id", socket.assigns.user.id
    case create_comment(params) do
      {:ok, comment} ->
        cids = socket.assigns.user_comment_ids ++ [comment.id]
        socket = assign(socket, :user_comment_ids, cids)

        feedback = case Enum.at(comment_response_ids(condition(socket)), Enum.count(cids)) do
          nil -> nil
          rid ->
            c = Enum.find(socket.assigns.bot_to_user_comments, fn c -> c.id == rid end)
            if not is_nil(c) do
              [
                NaiveDateTime.diff(c.inserted_at, user(socket).inserted_at),
                render_comment(c, user(socket))
              ]
            else
              nil
            end
        end

        comment = View.render_to_string(CommentView, "comment.html",
          comment: load_comment(comment, socket.assigns.user),
          user: socket.assigns.user
        )
        {:reply, {:ok, %{ comment: comment, feedback: feedback }}, socket}

      {:error, _changeset} ->
        {:reply, :error, socket}
    end
  end

  def handle_in("rate_idea", %{"id" => id, "rating" => rating }, socket) do
    case rate_idea! rating, id, socket.assigns.user.id do
      %{ "raters" => _, "rating" => _, "my_rating" => _ } = rating ->
        {:reply, {:ok, rating }, socket}
      _->
        {:reply, :error, socket}
    end
  end

  def handle_in("unrate_idea", %{"id" => id }, socket) do
    {:reply, {:ok, unrate_idea!(id, socket.assigns.user.id) }, socket}
  end

  def handle_in("like", %{"comment_id" => id, "like" => like }, socket) do
    case like_comment socket.assigns.user, id, like do
      {:ok, _comment} ->
        {:reply, :ok, socket}
      {:error, _} ->
        {:reply, :error, socket}
    end
  end

  # returns a list of ids for automated comments that have yet to be published,
  # includes both bot-to-bot and bot-to-user responses
  defp get_comment_schedule(socket) do
    u = user(socket)

    # get future bot-to-user comment responses to ideas
    r_ids = idea_response_ids condition(socket)
    bot_to_idea_responses = Enum.map(r_ids, fn id ->
      case Enum.find_index(r_ids, fn x -> x == id end) do
        nil -> nil
        index ->
          c = Enum.find(socket.assigns.bot_to_user_comments, fn c -> c.id == Enum.at(r_ids, index) end)
          case Enum.at(socket.assigns.user_idea_ids, index) do
            nil -> nil
            idea_id ->
              if not is_nil(c) and future(c.inserted_at) do
                remaining = NaiveDateTime.diff(c.inserted_at, u.inserted_at)
                [ idea_id, remaining, render_comment(c, u)]
              else
                nil
              end
          end
      end
    end) |> Enum.reject(&(is_nil(&1)))

    # get future bot-to-user comment responses to comments
    c_ids = comment_response_ids condition(socket)
    bot_to_comment_responses = Enum.map(c_ids, fn id ->
      case Enum.find_index(c_ids, fn x -> x == id end) do
        nil -> nil
        index ->
          c = Enum.find(socket.assigns.bot_to_user_comments, fn c -> c.id == Enum.at(c_ids, index) end)
          case Enum.at(socket.assigns.user_comment_ids, index) do
            nil -> nil
            idea_id ->
              if not is_nil(c) and future(c.inserted_at) do
                remaining = NaiveDateTime.diff(c.inserted_at, u.inserted_at)
                [ idea_id, remaining, render_comment(c, u) ]
              else
                nil
              end
          end
      end
    end) |> Enum.reject(&(is_nil(&1)))

    bot_to_idea_responses
    ++ bot_to_comment_responses
    ++ get_bot_to_bot_comments(u)
  end

  # gets the correct comment and sets posting date as a delay to idea date
  defp get_bot_comment(socket, rid, inserted_at) do
    comments = socket.assigns.bot_to_user_comments
    case Enum.find(comments, fn c -> c.id == rid end) do
      nil -> nil
      c -> Map.put(c, :inserted_at, NaiveDateTime.add(inserted_at, c.delay))
    end
  end

  # helper functions
  defp condition(socket), do: socket.assigns.user.condition
  defp topic_id(socket), do: socket.assigns.topic_id
  defp user(socket), do: socket.assigns.user
  defp user_idea_ids(socket), do: Map.get(socket.assigns, :user_idea_ids)
end
