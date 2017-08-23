defmodule Collaboration.ImportData do

  import Plug.Conn
  import Ecto.Query, only: [from: 2]

  alias Collaboration.Data
  alias Collaboration.Topic

  def init(default), do: default

  def call(conn, _) do

    instructions = Collaboration.Repo.get!(Data, 1)

    conn
    |> assign(:instructions, instructions.value)
    |> assign(:menutopics, Collaboration.Repo.all(from t in Topic,
          select: %{id: t.id, title: t.menutitle},
          where: t.hidden == false,
          order_by: [asc: t.order]
      ))
  end
end