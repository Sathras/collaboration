defmodule CollaborationWeb.TopicChannel do
  use CollaborationWeb, :channel

  require Logger

  import Collaboration.Contributions
  import CollaborationWeb.UserSocket, only: [schedule: 4]

  @experiment_duration Application.fetch_env!(:collaboration, :minTime)

  def join("topic", _params, socket) do

    # t = get_published_topic_id!()
    # u = user(socket)

    # # load bot-to-user comments and user_ideas (id and inserted_at)
    # socket = socket
    # |> assign(:topic_id, t)
    # |> assign(:bot_to_user_comments, get_bot_to_user_comments(u))
    # |> assign(:user_idea_ids, get_user_idea_ids(t, u))
    # |> assign(:user_comment_ids, get_user_comment_ids(u))

    # # schedule delayed events
    # send(self(), :after_join)

    # {:ok, %{
    #   condition: u.condition,
    #   ideas: load_future_ideas(t, u),
    #   comments: get_comment_schedule(socket),
    #   ratings: get_future_ratings(u),
    #   remaining: remaining(u.inserted_at, @experiment_duration),
    #   started: -remaining(u.inserted_at)
    # }, socket}

    {:ok, %{}, socket}
  end

  @doc """
  Schedule delayed events after socket has connected.
  """
  def handle_info(:after_join, socket) do

    # TODO: Schedule delayed events
    u = user(socket)

    # schedule future likes.
    # TODO: do not schedule passed likes, instead put them on topic load
    Enum.each(get_future_likes(u), fn([comment_id, delay]) ->
      Logger.debug "Like for comment ##{comment_id} scheduled in #{delay} sec."
      schedule(socket, "like", delay, %{ comment_id:  comment_id })
    end)

    {:noreply, socket}
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

  # helper functions
  defp condition(socket), do: socket.assigns.user.condition
  defp user(socket), do: socket.assigns.user
end
