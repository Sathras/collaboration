defmodule Collaboration.Accounts.User do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  alias Collaboration.Accounts.Credential
  alias Collaboration.Contributions.{ Idea, Comment, Rating }

  # verify new experiment users via passcode
  @passcode Application.fetch_env!(:collaboration, :passcode)

  schema "users" do

    field :name, :string
    field :condition, :integer, default: 0
    timestamps()
    field :completed_at, :naive_datetime_usec
    field :passcode, :string, virtual: true

    has_one :credential, Credential

    has_many :comments, Comment, on_delete: :delete_all
    has_many :ideas, Idea, on_delete: :delete_all
    has_many :ratings, Rating, on_delete: :delete_all

    many_to_many :likes, Comment, join_through: "likes", on_delete: :delete_all
  end

  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :completed_at, :passcode])
    |> validate_length(:name, min: 3, max: 20)
  end

  def experiment_changeset(user, params) do
    user
    |> changeset(params)
    |> validate_required([:name, :passcode])
    |> validate_change(:passcode, fn :passcode, passcode ->
        if passcode != @passcode, do: [passcode: "Passcode was wrong"], else: []
      end)
    |> put_condition(params)
  end

  def registration_changeset(user, params) do
    user
    |> changeset(params)
    |> validate_required([:name])
    |> put_change(:condition, 0)
    |> put_credential(params)
  end

  defp put_condition(user, params) do
    case Map.get(params, "name") do
      "*test_1*" -> put_change(user, :condition, 1)
      "*test_2*" -> put_change(user, :condition, 2)
      "*test_3*" -> put_change(user, :condition, 3)
      "*test_4*" -> put_change(user, :condition, 4)
      "*test_5*" -> put_change(user, :condition, 5)
      "*test_6*" -> put_change(user, :condition, 6)
      "*test_7*" -> put_change(user, :condition, 7)
      "*test_8*" -> put_change(user, :condition, 8)
      _ -> put_change(user, :condition, Enum.random(1..8))
    end
  end

  defp put_credential(user, params) do
    if Map.has_key?(params, :credential) do
      cast_assoc user, :credential,
        with: &Credential.changeset/2,
        required: true
    else
      user
    end
  end

  # def changeset(model, params \\ %{})

  # # create admin / peer user (via seed file)
  # def changeset(model, %{ :name => _, :email => _ } = params ) do
  #   model
  #   |> cast(params, [:name, :email] ++ coherence_fields())
  #   |> validate_required([:name, :email])
  #   |> validate_format(:email, ~r/@/)
  #   |> put_change(:password, @password)
  #   |> put_change(:password_confirmation, @password)
  #   |> unique_constraint(:email)
  #   |> validate_coherence(params)
  # end

  # def changeset(model, params) do
  #   model
  #   |> cast(params, [:name, :email] ++ coherence_fields())
  #   |> validate_required([:name, :email])
  #   |> validate_format(:email, ~r/@/)
  #   |> unique_constraint(:email)
  #   |> validate_coherence(params)
  # end

  # # create user for experiment ( via default registration )
  # def changeset(model, params, :experiment) do
  #   model
  #   |> cast(params, [:name, :passcode] ++ coherence_fields())
  #   |> validate_required([:name, :passcode])
  #   |> validate_length(:name, min: 3, max: 30)
  #   |> put_change(:passcode, String.downcase(Map.get(params, "passcode", "")))
  #   |> validate_inclusion(:passcode, [ @passcode ])
  #   |> put_change(:email, random_string(10) <>"@participant")
  #   |> put_change(:password, @password)
  #   |> put_change(:password_confirmation, @password)
  #   |> put_condition(params)
  #   |> validate_coherence(params)
  # end




  # defp random_string(length) do
  #   :crypto.strong_rand_bytes(length) |> Base.url_encode64 |> binary_part(0, length)
  # end
end
