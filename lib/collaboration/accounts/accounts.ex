defmodule Collaboration.Accounts do

  import Ecto.Query

  alias Collaboration.Accounts.User
  alias Collaboration.Repo

  # returns the condition of a user as an atom
  def condition(user), do: String.to_atom("c#{user.condition}")

  def create_user(params) do
    User.register_changeset(%User{}, params)
    |> Repo.insert()
  end

  def create_user(params, :admin) do
    User.admin_changeset(%User{}, params)
    |> Repo.insert!()
  end

  def get_user(id) do
    from(u in User, preload: [ :credential ])
    |> Repo.get(id)
  end

  def get_user_by_username(username) do
    from(u in User, join: c in assoc(u, :credential),
      where: c.username == ^username)
    |> Repo.one()
    |> Repo.preload(:credential)
  end

  def authenticate_by_username_and_pass(username, given_pass) do
    user = get_user_by_username(username)

    cond do
      user && Pbkdf2.verify_pass(given_pass, user.credential.password_hash) ->
        {:ok, user}
      user ->
        {:error, :unauthorized}
      true ->
        Pbkdf2.no_user_verify()
        {:error, :not_found}
    end
  end

  def list_participants() do
    from( u in User,
      select: map(u, ~w(id condition name inserted_at updated_at)a),
      order_by: u.inserted_at,
      where: u.condition > 0,
      limit: 2000
    ) |> Repo.all()
  end

  def list_users() do
    from( u in User,
      select: map(u, ~w(id name)a),
      where: u.condition == 0,
      limit: 100
    ) |> Repo.all()
  end

  def complete_user(user, completed) do
    Repo.update! User.complete_changeset(user, %{ completed: completed })
  end

  def time_passed(u) do
    NaiveDateTime.diff NaiveDateTime.utc_now(), u.inserted_at
  end
end
