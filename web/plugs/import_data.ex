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
    |> assign(:topics, Collaboration.Repo.all(from Topic, order_by: [asc: :order]))
  end
end