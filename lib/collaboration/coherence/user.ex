defmodule Collaboration.Coherence.User do
  @moduledoc false
  use Ecto.Schema
  use Coherence.Schema

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "users" do
    field(:admin, :boolean, default: false)
    field(:name, :string)
    field(:email, :string)
    field(:feedback, :boolean, default: false)
    coherence_schema()
    timestamps()

    has_many(
      :comments,
      Collaboration.Contributions.Comment,
      on_delete: :delete_all
    )

    has_many(
      :feedbacks,
      Collaboration.Contributions.Comment,
      on_delete: :delete_all
    )

    has_many(:ideas, Collaboration.Contributions.Idea, on_delete: :delete_all)

    has_many(
      :ratings,
      Collaboration.Contributions.Rating,
      on_delete: :delete_all
    )

    many_to_many(
      :likes,
      Collaboration.Contributions.Comment,
      join_through: "likes",
      on_delete: :delete_all
    )
  end

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, [:name, :email] ++ coherence_fields())
    |> feedback_condition()
    |> validate_required([:name, :email])
    |> validate_format(:email, ~r/@/)
    |> unique_constraint(:email)
    |> validate_coherence(params)
  end

  def changeset(model, params, :toggle) do
    model
    |> cast(params, ~w(admin feedback))
  end

  def changeset(model, params, :password) do
    model
    |> cast(
      params,
      ~w(password password_confirmation reset_password_token reset_password_sent_at)
    )
    |> validate_coherence_password_reset(params)
  end

  def feedback_condition(model) do
    if model.data.feedback === nil do
      random = Enum.random(0..1)
      random = if random >= 0.5, do: true, else: false
      model |> put_change(:feedback, random)
    else
      model
    end
  end
end
