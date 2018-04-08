defmodule CollaborationWeb.Plug.LoadTopics do

  import Plug.Conn
  import CollaborationWeb.ViewHelpers, only: [admin?: 1]

  def init(opts), do: opts

  def call(conn, _opts) do
    topics = Collaboration.Contributions.list_topics(admin?(conn))
    assign(conn, :topics, topics)
  end
end