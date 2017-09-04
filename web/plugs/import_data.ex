defmodule Collaboration.ImportData do

  import Plug.Conn
  import Ecto.Query, only: [from: 2]

  alias Collaboration.Data
  alias Collaboration.Topic
  alias Collaboration.TopicView
  alias Collaboration.Repo
  alias Phoenix.View

  def init(default), do: default

  def call(conn, _) do

    instructions = Repo.get!(Data, 1)
    menutopics = Repo.all(from t in Topic,
      select: %{id: t.id, menutitle: t.menutitle, order: t.order},
      where: t.hidden == false,
      order_by: [asc: t.order]
    )

    conn
    |> assign(:instructions, instructions.value)
    |> assign(:menutopics, View.render_many(menutopics, TopicView, "topic-menu.json"))
  end
end