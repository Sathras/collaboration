# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#

alias Collaboration.Repo
alias Collaboration.Coherence.User
alias Collaboration.Contributions.Topic

Collaboration.Repo.delete_all Collaboration.Coherence.User

{:ok, admin} = User.changeset(%User{},
%{
  admin: true,
  name: "Alexander Fuchsberger",
  email: "alex@fuchsberger.us",
  password: "password",
  password_confirmation: "password"
})
|> Repo.insert!
|> Coherence.ConfirmableService.confirm!

User.changeset(admin, %{admin: true}, :toggle)
|> Repo.update!

## add some sample topics
Topic.changeset(%Topic{},
%{
  id: 1,
  slug: "topic-1",
  title: "First Topic",
  short_title: "Topic 1",
  published: true,
  open: true,
  featured: true,
  short_desc: "<p>This topic is open for editing and has been published and featured. Thus it appears in the navigation bar!</p>",
  desc: "<p>This topic is open for editing and has been published and featured. Thus it appears in the navigation bar!</p>"
}) |> Repo.insert!

Topic.changeset(%Topic{},
%{
  id: 2,
  slug: "topic-2",
  title: "Second Topic",
  short_title: "Topic 2",
  published: true,
  open: false,
  featured: true,
  short_desc: "<p>This topic is featured and published. Thus it appears in the navigation bar. Since it is closed, however, normal users cannot add ideas, comments, likes and ratings.</p>",
  desc: "<p>This topic is featured and published. Thus it appears in the navigation bar. Since it is closed, however, normal users cannot add ideas, comments, likes and ratings.</p>"
}) |> Repo.insert!

Topic.changeset(%Topic{},
%{
  id: 3,
  slug: "topic-3",
  title: "Third Topic",
  short_title: "Topic 3",
  published: true,
  open: true,
  featured: false,
  short_desc: "<p>This topic is not featured. Thus it only appears in the topic list.</p>",
  desc: "<p>This topic is not featured. Thus it only appears in the topic list.</p>"
}) |> Repo.insert!

Topic.changeset(%Topic{},
%{
  id: 4,
  slug: "topic-4",
  title: "Fourth Topic",
  short_title: "Topic 4",
  published: false,
  open: true,
  featured: true,
  short_desc: "<p>This topic is not published. Thus it is only visible to administrators. Notice that even though the topic is featured it does not appear in the navigation bar. Also, normal users can not collaborate on the topic even though it is open.</p>",
  desc: "<p>This topic is not published. Thus it is only visible to administrators. Notice that even though the topic is featured it does not appear in the navigation bar. Also, normal users can not collaborate on the topic even though it is open.</p>"
}) |> Repo.insert!