defmodule CollaborationWeb.TopicCommander do
  use CollaborationWeb, :commander
  alias CollaborationWeb.IdeaView
  alias CollaborationWeb.CommentView

  defhandler delete_comment(socket, _sender, comment_id) do
    if delete_comment!(comment_id), do: delete!(socket, "#comment#{comment_id}")
  end

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
    liked = socket |> select( data: "liked", from: elm )
    likes = socket |> select( data: "likes", from: elm )
    user = get_user!(socket.assigns.user_id)
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

  defhandler rate(socket, sender, idea_id) do
    rating = sender["data"]["rating"]
    user = get_user!(socket.assigns.user_id)
    if rate_idea!(user, idea_id, rating) do

      idea = render_to_string IdeaView, "idea.html",
        action_delete: socket |> select(attr: "href", from: "#idea#{idea_id} .delete-link"),
        action_edit: socket |> select(attr: "href", from: "#idea#{idea_id} .edit-link"),
        admin: user.admin,
        idea: load_idea(idea_id, user),
        user_id: user.id

      socket
      |> execute(replaceWith: idea, on: "#idea#{idea_id}")
      |> execute(:timeago, on: "#idea#{idea_id} time")
    end
  end

  defhandler submit_feedback(socket, sender, idea_id) do
    if sender["event"]["keyCode"] === 13 do
      user = get_user!(socket.assigns.user_id)
      case create_comment(user, idea_id, %{text: sender["value"]}) do
        {:ok, comment} ->
          comment = render_to_string CommentView, "comment.html",
            admin: user.admin,
            comment: load_comment(comment.id, user),
            user_id: user.id
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

  defhandler toggle(socket, sender, topic_id) do
    param = sender["data"]["param"]
    value = !sender["data"]["value"]
    case update_topic(get_topic!(topic_id), Map.put(%{}, param, value)) do
      {:ok, _topic} ->
        toggle = if param == "featured",
          do: "text-primary text-muted",
          else: "fa-eye fa-eye-slash text-muted"
        socket
        |> update!(:class, toggle: toggle, on: this(sender))
        |> update!(attr: "data-value", set: value, on: this(sender))
      {:error, _changeset} ->
        socket |> exec_js("console.log('Something went wrong!');")
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
