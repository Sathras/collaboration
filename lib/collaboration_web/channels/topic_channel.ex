defmodule CollaborationWeb.TopicChannel do
  use CollaborationWeb, :channel

  alias Phoenix.View
  alias CollaborationWeb.{ IdeaView, CommentView }

  @experiment_duration Application.fetch_env!(:collaboration, :minTime)

  def join("topic", _params, socket) do
    t = get_featured_topic_id!()
    u = user(socket)

    send(self, :after_join)

    # load bot-to-user comments and user_ideas (id and inserted_at)
    socket = socket
    |> assign(:topic_id, t)
    |> assign(:bot_to_user_comments, get_bot_to_user_comments(u))
    |> assign(:user_idea_ids, get_user_idea_ids(t, u))
    |> assign(:user_comment_ids, get_user_comment_ids(u))

    {:ok, %{
      condition: u.condition,
      ideas: load_future_ideas(t, u),
      comments: get_comment_schedule(socket),
      likes: get_future_likes(u),
      ratings: get_future_ratings(u),
      remaining: remaining(u.inserted_at, @experiment_duration),
      started: -remaining(u.inserted_at)
    }, socket}
  end

  def handle_info(:after_join, socket) do

    # test: send delayed message after 3 sec
    schedule(socket, "test", 3000, %{ msg: "Test: This message should appear after 3 sec."})

    {:noreply, socket}
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
          rid -> case get_bot_comment(socket, rid, idea.inserted_at) do
            nil -> nil
            c -> [ idea.id, render_comment(c, u), c.delay ]
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
    u = user(socket)
    case create_comment(params, u) do
      {:ok, comment} ->

        # add comment_id to comment_ids in socket
        ids = user_comment_ids(socket)
        socket = assign socket, :user_comment_ids, ids ++ [comment.id]

        # determine if a response comment should be prepared
        f = case Enum.at(comment_response_ids(u.condition), Enum.count(ids)) do
          nil -> nil
          rid -> case get_bot_comment(socket, rid, comment.inserted_at) do
            nil -> nil
            c -> [ comment.idea_id, render_comment(c, u), c.delay ]
          end
        end

        # prepare comment for socket
        c = comment
        |> View.render_one(CommentView, "comment.json", user: u )
        |> render_comment(u)

        { :reply, {:ok, %{ comment: [ comment.idea_id, c ], feedback: f }}, socket}

      {:error, _changeset} ->
        {:reply, :error, socket}
    end
  end

  def handle_in("rate_idea", %{"id" => id, "rating" => rating }, socket) do
    {:reply, {:ok, rate_idea!(rating, id, socket.assigns.user.id) }, socket }
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
            { idea_id, inserted } ->
              if not is_nil(c) and inserted + c.delay > 0 do
                [ idea_id, render_comment(c, u), inserted + c.delay ]
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
              if not is_nil(c) and remaining(c.inserted_at) > 0 do
                [ idea_id, render_comment(c, u), remaining(c.inserted_at) ]
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
  defp user_comment_ids(socket), do: Map.get(socket.assigns, :user_comment_ids)
end
