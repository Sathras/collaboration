defmodule CollaborationWeb.TopicCommander do
  use CollaborationWeb, :commander
  alias CollaborationWeb.IdeaView
  alias CollaborationWeb.CommentView

  defhandler edit(socket, sender, idea_id) do
    if "I" === select socket, prop: "nodeName", from: this(sender) do
      value = select socket, :text, from: "#idea#{idea_id} .card-text"
      input = """
        <textarea
          class=\"card-text form-control p-0 border-0\"
          onkeyup=\"auto_grow(this)\"
          drab-change=\"edit(#{idea_id})\"
          placeholder=\"Edit Idea Text\"
        >#{value}</textarea>
      """
      socket
      |> execute(replaceWith: input, on: "#idea#{idea_id} .card-text")
      |> execute(:focus, on: "#idea#{idea_id} .card-text")
      |> exec_js("""
        auto_grow($("#idea#{idea_id} .card-text")[0]);
        Drab.enable_drab_on(\"#idea#{idea_id} .card-text\");
        """)
    else
      case update_idea(get_idea!(idea_id), %{text: sender["value"]}) do
        {:ok, idea} ->
          p = "<p class=\"card-text\">#{idea.text}</p>"
          socket
          |> execute(replaceWith: p, on: "#idea#{idea_id} .card-text")

        {:error, _changeset} ->
          insert(socket, class: "is-invalid", into: "#idea#{idea_id} .card-text")
      end
    end
  end

  defhandler like(socket, sender, comment_id) do
    elm = "#comment#{comment_id}"
    likes = socket |> select( data: "likes", from: elm )

    if select(socket, data: "liked", from: elm ) do
      if unlike_comment(socket.assigns.user, comment_id) do
        if likes === 0, do:
          socket |> insert(class: "d-none", into: elm <> " span.likes")
        socket
        |> update(data: "liked", set: false, on: elm)
        |> update(:text, set: "Like", on: this(sender))
        |> update(:text, set: likes, on: elm <> " span.likes")
        |> execute("val(#{likes})", on: elm <> " input")
      end
    else
      if like_comment(socket.assigns.user, comment_id) do
        socket
        |> update(data: "liked", set: true, on: elm)
        |> update(:text, set: "Unlike", on: this(sender))
        |> update(:text, set: likes + 1, on: elm <> " span.likes")
        |> delete(class: "d-none", from: elm <> " span.likes")
        |> execute("val(#{likes + 1})", on: elm <> " input")
      end
    end
  end

  defhandler rate(socket, sender, idea_id) do
    user = socket.assigns.user
    if rate_idea!(sender["data"]["rating"], idea_id, user.id) do

      idea = render_to_string IdeaView, "idea.html",
        idea: load_idea(idea_id, user),
        user: user

      socket
      |> execute(replaceWith: idea, on: "#idea#{idea_id}")
      |> execute(:timeago, on: "#idea#{idea_id} time")
    end
  end

  defhandler unrate(socket, _sender, idea_id) do
    unrate_idea!(idea_id, socket.assigns.user.id)
    exec_js(socket, "unrate(#{idea_id})")
  end

  defhandler submit_feedback(socket, sender, idea_id) do
    if sender["event"]["keyCode"] === 13 do
      user = socket.assigns.user
      comment = %{
        text: sender["value"],
        user_id: user.id,
        idea_id: idea_id
      }
      case create_comment(comment) do
        {:ok, comment} ->

          comment = render_to_string CommentView, "comment.html",
            comment: load_comment(comment.id, user),
            user: user

          socket
          |> insert(comment, append: "#idea#{idea_id} .comments")
          |> delete(class: "is-invalid", from: this(sender))
          |> execute("val('')", on: this(sender))
          |> exec_js("$('#idea#{idea_id} .comments time:last').timeago();")

        {:error, _changeset} ->
          socket
          |> insert(class: "is-invalid", into: this(sender))
      end
    end
  end

  defhandler update_fake_likes(socket, sender, comment_id) do
    elm = "#comment#{comment_id}"
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
