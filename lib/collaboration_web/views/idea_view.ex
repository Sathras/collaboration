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

  def rating(idea) do
    r_rate = if Decimal.decimal?(idea[:real_rating]), do: Decimal.to_float(idea[:real_rating]), else: 0
    r_count = idea[:real_raters]
    f_rate = idea[:fake_rating]
    f_count = idea[:fake_raters]
    sum = r_count + f_count
    if sum > 0, do: Float.round((r_rate * r_count + f_rate * f_count) / sum, 2),
    else: ""
  end
end
