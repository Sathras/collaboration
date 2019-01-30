defmodule CollaborationWeb.Plug.LoadTopics do
  import Plug.Conn
  import Collaboration.Contributions, only: [get_topic_titles!: 1]

  def init(opts), do: opts
  def call(conn, _opts) do
    condition = conn.assigns.current_user.condition
    assign conn, :nav_topics, get_topic_titles!(condition)
  end
end
