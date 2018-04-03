# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#

Collaboration.Repo.delete_all Collaboration.Coherence.User

Collaboration.Coherence.User.changeset(%Collaboration.Coherence.User{}, %{
  name: "Alexander Fuchsberger",
  email: "alex@fuchsberger.us",
  password: "password",
  password_confirmation: "password"
})
|> Collaboration.Repo.insert!
|> Coherence.ConfirmableService.confirm!