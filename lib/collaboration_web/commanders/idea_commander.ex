defmodule CollaborationWeb.IdeaCommander do
  use CollaborationWeb, :commander

  alias CollaborationWeb.CommentView
  import CollaborationWeb.IdeaView, only: [calc_rating: 4]

  defhandler delete_comment(socket, sender, comment_id) do
    if delete_comment!(comment_id) do
      socket |> delete!("#comments [data-id=#{comment_id}]")
    end
  end

  defhandler submit_feedback(socket, sender, idea_id) do
    user = peek socket, :user
    case create_comment(user, idea_id, %{text: sender["value"]}) do
      {:ok, comment} ->
        comment = render_to_string CommentView, "comment.html",
          comment: load_comment(comment.id, user.id),
          user: user
        socket
        |> insert(comment, append: "#comments")
        |> exec_js("$('#comments time:last').timeago();")
        |> delete(class: "is-invalid", from: this(sender))
        |> execute("val('')", on: this(sender))

      {:error, _changeset} ->
        socket
        |> insert(class: "is-invalid", into: this(sender))
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
    idea = peek socket, :idea
    user = peek socket, :user
    rating = String.to_integer sender["value"]
    if rate_idea!(user, idea.id, rating) do
      {rating, raters}
        = calc_rating(idea.rating, idea.raters, rating, idea.my_rating)
      socket
      |> update(:text, set: rating, on: "#rating")
      |> update(:text, set: raters, on: "#raters")
      |> execute("prop(\"checked\", true).trigger(\"click\")", on: this(sender))
    end
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
