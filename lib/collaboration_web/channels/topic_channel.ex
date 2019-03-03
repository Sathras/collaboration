defmodule CollaborationWeb.TopicChannel do
  use CollaborationWeb, :channel

  alias Phoenix.View
  alias CollaborationWeb.{ IdeaView, CommentView }

  def join("topic", _params, socket) do

    # load bot-to-user comments and user_ideas (id and inserted_at)
    socket = socket
    |> assign(:bot_to_user_comments, get_bot_to_user_comments(user(socket)))
    |> assign(:user_idea_ids, get_user_idea_ids(topic_id(socket), user(socket)))
    |> assign(:user_comment_ids, get_user_comment_ids(user(socket)))

    {:ok, %{
      ideas: get_idea_schedule(socket),       # get ideas to be published
      comments: get_comment_schedule(socket)  # get comments to be published
    }, socket}
  end

  def handle_in("create_idea", params, socket) do
    params = Map.put params, "user_id", socket.assigns.user.id
    case create_idea(params, socket.assigns.topic_id, socket.assigns.user) do
      {:ok, idea } ->

        idea_ids = socket.assigns.user_idea_ids ++ [idea.id]
        socket = assign(socket, :user_comment_ids, idea_ids)

        feedback = case Enum.at(idea_response_ids(condition(socket)), Enum.count(idea_ids)) do
          nil -> nil
          rid ->
            c = Enum.find(socket.assigns.bot_to_user_comments, fn c -> c.id == rid end)
            IO.inspect c
            if not is_nil(c) do
              [
                idea.id,
                time_passed(socket) + c.remaining,
                View.render_to_string(CommentView, "comment.html", comment: c, user: user(socket))
              ]
            else
              nil
            end
        end

        idea = View.render_to_string IdeaView, "idea.html",
          idea: View.render_one(idea, IdeaView, "idea.json", user: socket.assigns.user),
          user: socket.assigns.user

        {:reply, {:ok, %{ idea: idea, feedback: feedback }}, socket}

      { :error, _changeset } ->
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
                time_passed(socket) + c.remaining,
                View.render_to_string(CommentView, "comment.html", comment: c, user: user(socket))
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

  @doc """
    returns a list of ids for automated ideas that have yet to be published

    @param socket
    @return
      list [[ idea_id, remaining ], ...]
      idea_id     = id of idea where to attach it to,
      remaining   = when to attach it to [sec]
  """
  defp get_idea_schedule(socket) do
    load_future_ideas(topic_id(socket), user(socket))
    |> Enum.map(fn i -> [
      i.remaining,
      View.render_to_string(IdeaView, "idea.html", idea: i, user: user(socket))
    ] end)
  end

  @doc """
    returns a list of ids for automated comments that have yet to be published,
    both bot-to-bot and bot-to-user responses

    @param socket
    @return
      list [[ idea_id, remaining, comment ], ...]
      idea_id     = id of idea where to attach it to,
      remaining   = when to attach it to [sec]
      comment     = html of comment
  """
  defp get_comment_schedule(socket) do
    u = user(socket)
    time = time_passed socket

    # get future bot-to-user comment responses to ideas
    r_ids = idea_response_ids condition(socket)
    bot_to_idea_responses = Enum.map(r_ids, fn id ->
      case Enum.find_index(r_ids, fn x -> x == id end) do
        nil -> nil
        index ->
          c = Enum.find(socket.assigns.bot_to_user_comments, fn c -> c.id == Enum.at(r_ids, index) end)
          case Enum.at(socket.assigns.user_idea_ids, index) do
            nil -> nil
            { idea_id, passed } ->
              if not is_nil(c) and c.remaining + passed > 0 do
                [ idea_id, c.remaining + passed, View.render_to_string(
                  CommentView, "comment.html", comment: c, user: u )]
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
            { idea_id, passed } ->
              if not is_nil(c) and c.remaining + passed > 0 do
                [ idea_id, c.remaining + passed, View.render_to_string(
                  CommentView, "comment.html", comment: c, user: u )]
              else
                nil
              end
          end
      end
    end) |> Enum.reject(&(is_nil(&1)))

    # get future bot-to-bot comments
    bot_to_bot_comments = get_bot_to_bot_comments(u)
    |> Enum.map(fn c -> [ c.idea_id, c.remaining, View.render_to_string(
      CommentView, "comment.html", comment: c, user: u )] end)

    bot_to_idea_responses ++ bot_to_comment_responses ++ bot_to_bot_comments
  end

  defp time_passed(socket) do
    NaiveDateTime.diff NaiveDateTime.utc_now(), socket.assigns.user.inserted_at
  end

  defp condition(socket), do: socket.assigns.user.condition
  defp topic_id(socket), do: socket.assigns.topic_id
  defp user(socket), do: socket.assigns.user
end

