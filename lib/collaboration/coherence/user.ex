defmodule Collaboration.Coherence.User do
  @moduledoc false
  use Ecto.Schema
  use Coherence.Schema

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "users" do
    field :admin, :boolean, default: false
    field :name, :string
    field :email, :string
    coherence_schema()
    timestamps()
    has_many :comments, Collaboration.Contributions.Comment, on_delete: :delete_all
    has_many :ideas, Collaboration.Contributions.Idea, on_delete: :delete_all
    has_many :ratings, Collaboration.Contributions.Rating, on_delete: :delete_all
    many_to_many :likes, Collaboration.Contributions.Comment, join_through: "likes", on_delete: :delete_all
  end

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, [:name, :email] ++ coherence_fields())
    |> validate_required([:name, :email])
    |> validate_format(:email, ~r/@/)
    |> unique_constraint(:email)
    |> validate_coherence(params)
  end

  def changeset(model, params, :toggle) do
    model
    |> cast(params, ~w(admin))
  end

  def changeset(model, params, :password) do
    model
    |> cast(params, ~w(password password_confirmation reset_password_token reset_password_sent_at))
    |> validate_coherence_password_reset(params)
  end
end
