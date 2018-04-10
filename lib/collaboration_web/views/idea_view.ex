defmodule CollaborationWeb.IdeaView do
  use CollaborationWeb, :view

  def like_label(conn, comment) do
    user_ids = Enum.map(comment.likes, fn(u) -> u.id end)
    if Enum.member? user_ids, Coherence.current_user(conn).id do
      "Unlike"
    else
      "Like"
    end
  end
end
