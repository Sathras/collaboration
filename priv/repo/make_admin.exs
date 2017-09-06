# Script for making the first user a admin
#
#     mix run priv/repo/make_admin.exs
#

alias Collaboration.Repo
alias Collaboration.User

user = Repo.get!(User, 1)
user = Ecto.Changeset.change user, admin: true

case Repo.update user do
  {:ok, _struct}       -> "User was updated!"
  {:error, _changeset} -> "Something went wrong"
end
