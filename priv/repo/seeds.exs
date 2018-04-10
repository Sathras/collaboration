# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#

import Ecto.Changeset

alias Collaboration.Repo
alias Collaboration.Coherence.User
alias Collaboration.Contributions.Topic
alias Collaboration.Contributions.Idea

Collaboration.Repo.delete_all Collaboration.Coherence.User

{:ok, admin} = User.changeset(%User{},
%{
  id: <<113, 148, 42, 145, 149, 203, 69, 49, 158, 34, 160, 79, 67, 170, 215, 61>>,
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
topic1 = Topic.changeset(%Topic{},
%{
  id: 1,
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
  title: "Fourth Topic",
  short_title: "Topic 4",
  published: false,
  open: true,
  featured: true,
  short_desc: "<p>This topic is not published. Thus it is only visible to administrators. Notice that even though the topic is featured it does not appear in the navigation bar. Also, normal users can not collaborate on the topic even though it is open.</p>",
  desc: "<p>This topic is not published. Thus it is only visible to administrators. Notice that even though the topic is featured it does not appear in the navigation bar. Also, normal users can not collaborate on the topic even though it is open.</p>"
}) |> Repo.insert!

Idea.changeset(%Idea{},
%{
  id: 1,
  title: "First Idea",
  desc: "This idea was premade and has a fake-rating of 4.3 (through 5 fake raters).",
  fake_raters: 5,
  fake_rating: 4.3
})
|> put_assoc(:topic, topic1)
|> put_assoc(:user, admin)
|> Repo.insert!