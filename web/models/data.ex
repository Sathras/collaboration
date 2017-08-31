defmodule Collaboration.Data do
  use Collaboration.Web, :model

  schema "data" do
    field :field, :string
    field :value, :string
    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, ~w(field value))
    |> validate_required([:value])
    |> unique_constraint(:field)
  end
end
