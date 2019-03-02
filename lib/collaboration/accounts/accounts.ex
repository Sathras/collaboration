defmodule Collaboration.Accounts do

  import Ecto.Query

  alias Collaboration.Accounts.User
  alias Collaboration.Repo

  def get_user(id) do
    Repo.get(User, id)
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
      user && Comeonin.Pbkdf2.checkpw(given_pass, user.credential.password_hash) ->
        {:ok, user}

      user ->
        {:error, :unauthorized}

      true ->
        Comeonin.Pbkdf2.dummy_checkpw()
        {:error, :not_found}
    end
  end

  def change_user(user \\ %User{}, params \\ %{}) do
    User.changeset user, params
  end

  def create_participant(params) do
    %User{}
    |> User.experiment_changeset(params)
    |> Repo.insert()
  end

  def list_participants() do
    from( u in User,
      select: map(u, ~w(condition name inserted_at completed_at)a),
      order_by: u.inserted_at,
      where: u.condition > 0,
      limit: 2000
    ) |> Repo.all()
  end

  def list_users() do
    from( u in User,
      select: map(u, ~w(id name inserted_at)a),
      order_by: u.inserted_at,
      where: u.condition == 0,
      limit: 100
    ) |> Repo.all()
  end

  def update_user!(user, params) do
    Repo.update! change_user(user, params)
  end

  def register_user!(attrs \\ %{}) do
    %User{}
    |> User.registration_changeset(attrs)
    |> Repo.insert!()
  end

  # TODO: delete or verify all these below:

  def select_random_user(user_id) do
    from( u in User,
      order_by: fragment("RANDOM()"),
      where: u.id != ^user_id and u.condition == 0,
      limit: 1)
    |> Repo.all()
    |> List.first()
  end

  def get_user!(id) do
    Repo.get!(User, id)
  end

  def update_user(user, params) do
    Repo.update(change_user(user, params))
  end
end
