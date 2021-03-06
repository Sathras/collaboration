defmodule Collaboration.Accounts.Credential do
  use Ecto.Schema
  import Ecto.Changeset

  schema "credentials" do
    field :username, :string
    field :password, :string, virtual: true
    field :password_hash, :string
    belongs_to :user, Collaboration.Accounts.User
    timestamps()
  end

  @doc false
  def changeset(credential, attrs) do
    credential
    |> cast(attrs, [:username, :password])
    |> validate_required([:username, :password])
    |> validate_length(:password, min: 6, max: 100)
    |> unique_constraint(:username)
    |> put_pass_hash()
  end

  defp put_pass_hash(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: password }} ->
        put_change changeset, :password_hash, Pbkdf2.hash_pwd_salt(password)
      _ ->
        changeset
    end
  end
end
