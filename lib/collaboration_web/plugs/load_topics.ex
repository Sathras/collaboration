defmodule CollaborationWeb.Plug.LoadTopics do
  import Plug.Conn
  import Collaboration.Contributions, only: [get_topic_titles!: 0]

  def init(opts), do: opts
  def call(conn, _opts), do: assign(conn, :nav_topics, get_topic_titles!())
end
