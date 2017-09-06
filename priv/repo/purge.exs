# Script for removing all ideas, comments and reactions from the database.
#
#     You can run it as:
#     mix run priv/repo/purge.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Collaboration.Repo.insert!(%Collaboration.SomeModel{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Collaboration.Repo

Repo.delete_all(Collaboration.Reaction)
Repo.delete_all(Collaboration.Comment)
Repo.delete_all(Collaboration.Idea)