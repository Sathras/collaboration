defmodule CollaborationWeb.IdeaCommander do
  use CollaborationWeb, :commander

  after_handler :timeago, except: [:toggle]

  def timeago(socket, _sender, _retval) do
    socket |> exec_js("$('time').timeago();")
  end

  defhandler submit_feedback(socket, sender) do
    input = this(sender)
    idea_id = peek socket, :idea
    user = peek socket, :user
    case create_comment(user, idea_id, %{text: sender["value"]}) do
      {:ok, _comment} ->
        update_comments(socket, user)
        socket
        |> delete(class: "is-invalid", from: input)
        |> set_prop(input, value: "")
      {:error, _changeset} ->
        socket
        |> insert(class: "is-invalid", into: input)
    end
  end

  defhandler like(socket, sender, comment_id) do
    elm = "#comments [data-id=#{comment_id}]"
    liked = socket |> select( data: "liked", from: elm )
    likes = socket |> select( data: "likes", from: elm )
    user = peek socket, :user
    if liked do
      if unlike_comment(user, comment_id) do
        socket
        |> update(data: "liked", set: false, on: elm)
        |> update(:text, set: "Like", on: this(sender))
        |> update(:text, set: likes, on: elm <> " span.likes")
        |> execute("val(#{likes})", on: elm <> " input")
      end
    else
      if like_comment(user, comment_id) do
        socket
        |> update(data: "liked", set: true, on: elm)
        |> update(:text, set: "Unlike", on: this(sender))
        |> update(:text, set: likes + 1, on: elm <> " span.likes")
        |> execute("val(#{likes + 1})", on: elm <> " input")
      end
    end
  end

  defhandler rate(socket, sender) do
    idea_id = peek socket, :idea
    user = peek socket, :user
    if rate_idea!(user, idea_id, sender["value"]),
      do: update_comments(socket, user)
  end

  defp update_comments(socket, user) do
    idea = peek socket, :idea
    poke socket, comments: load_comments(idea.id, user)
  end

  defhandler update_fake_likes(socket, sender, comment_id) do
    elm = "#comments [data-id=#{comment_id}]"
    likes = socket |> select( data: "likes", from: elm )
    new_likes = String.to_integer sender["value"]
    case update_comment(comment_id, %{fake_likes: new_likes}) do
      {:ok, _comment} ->
        liked = socket |> select( data: "liked", from: elm )
        likes = if liked, do: new_likes + 1, else: new_likes
        socket
        |> update(data: "likes", set: new_likes, on: elm)
        |> execute("val(#{likes})", on: this(sender))
      {:error, _changeset} ->
        socket |> execute("val(#{likes})", on: this(sender))
    end
  end
end
