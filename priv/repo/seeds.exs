# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#

import Ecto.Changeset

alias Collaboration.Repo
alias Collaboration.Coherence.User
alias Collaboration.Contributions.Topic
alias Collaboration.Contributions.Idea

Collaboration.Repo.delete_all(Collaboration.Coherence.User)

{:ok, alex} =
  User.changeset(%User{}, %{
    name: "Alexander Fuchsberger",
    email: "alex@fuchsberger.us",
    password: "password",
    password_confirmation: "password"
  })
  |> Repo.insert!()
  |> Coherence.ConfirmableService.confirm!()

{:ok, gj} =
  User.changeset(%User{}, %{
    name: "GJ",
    email: "gdevreede@usf.edu",
    password: "password",
    password_confirmation: "password"
  })
  |> Repo.insert!()
  |> Coherence.ConfirmableService.confirm!()

{:ok, triparna} =
  User.changeset(%User{}, %{
    name: "Triparna",
    email: "tdevreede@usf.edu ",
    password: "password",
    password_confirmation: "password"
  })
  |> Repo.insert!()
  |> Coherence.ConfirmableService.confirm!()

{:ok, nargess} =
  User.changeset(%User{}, %{
    name: "Nargess",
    email: "nargess.tahmasbi@gmail.com",
    password: "password",
    password_confirmation: "password"
  })
  |> Repo.insert!()
  |> Coherence.ConfirmableService.confirm!()

{:ok, john} =
  User.changeset(%User{}, %{
    name: "John",
    email: "test1@test.com",
    password: "password",
    password_confirmation: "password"
  })
  |> Repo.insert!()
  |> Coherence.ConfirmableService.confirm!()

{:ok, sarah} =
  User.changeset(%User{}, %{
    name: "Sarah",
    email: "test2@test.com",
    password: "password",
    password_confirmation: "password"
  })
  |> Repo.insert!()
  |> Coherence.ConfirmableService.confirm!()

{:ok, kjetil} =
  User.changeset(%User{}, %{
    name: "Kjetil",
    email: "test3@test.com",
    password: "password",
    password_confirmation: "password"
  })
  |> Repo.insert!()
  |> Coherence.ConfirmableService.confirm!()

{:ok, sam} =
  User.changeset(%User{}, %{
    name: "Nargess",
    email: "test4@test.com",
    password: "password",
    password_confirmation: "password"
  })
  |> Repo.insert!()
  |> Coherence.ConfirmableService.confirm!()

{:ok, hannah} =
  User.changeset(%User{}, %{
    name: "Hannah",
    email: "test5@test.com",
    password: "password",
    password_confirmation: "password"
  })
  |> Repo.insert!()
  |> Coherence.ConfirmableService.confirm!()

{:ok, claudia} =
  User.changeset(%User{}, %{
    name: "Claudia",
    email: "test6@test.com",
    password: "password",
    password_confirmation: "password"
  })
  |> Repo.insert!()
  |> Coherence.ConfirmableService.confirm!()

{:ok, tim} =
  User.changeset(%User{}, %{
    name: "Tim",
    email: "test7@test.com",
    password: "password",
    password_confirmation: "password"
  })
  |> Repo.insert!()
  |> Coherence.ConfirmableService.confirm!()

# make the following users feedback users:
User.changeset(nargess, %{feedback: true}, :toggle) |> Repo.update!()
User.changeset(john, %{feedback: true}, :toggle) |> Repo.update!()
User.changeset(sarah, %{feedback: true}, :toggle) |> Repo.update!()
User.changeset(triparna, %{feedback: true}, :toggle) |> Repo.update!()

# make the following users admins:
User.changeset(alex, %{admin: true}, :toggle) |> Repo.update!()
User.changeset(gj, %{admin: true}, :toggle) |> Repo.update!()
User.changeset(triparna, %{admin: true}, :toggle) |> Repo.update!()

## add some sample topics
topic1 =
  Topic.changeset(%Topic{}, %{
    id: 1,
    title: "First Topic",
    short_title: "Topic 1",
    published: true,
    open: true,
    featured: true,
    short_desc:
      "<p>This topic is open for editing and has been published and featured. Thus it appears in the navigation bar!</p>",
    desc:
      "<p>This topic is open for editing and has been published and featured. Thus it appears in the navigation bar!</p>"
  })
  |> Repo.insert!()

Topic.changeset(%Topic{}, %{
  id: 2,
  title: "Second Topic",
  short_title: "Topic 2",
  published: true,
  open: false,
  featured: true,
  short_desc:
    "<p>This topic is featured and published. Thus it appears in the navigation bar. Since it is closed, however, normal users cannot add ideas, comments, likes and ratings.</p>",
  desc:
    "<p>This topic is featured and published. Thus it appears in the navigation bar. Since it is closed, however, normal users cannot add ideas, comments, likes and ratings.</p>"
})
|> Repo.insert!()

Topic.changeset(%Topic{}, %{
  id: 3,
  title: "Third Topic",
  short_title: "Topic 3",
  published: true,
  open: true,
  featured: false,
  short_desc:
    "<p>This topic is not featured. Thus it only appears in the topic list.</p>",
  desc:
    "<p>This topic is not featured. Thus it only appears in the topic list.</p>"
})
|> Repo.insert!()

Topic.changeset(%Topic{}, %{
  id: 4,
  title: "Fourth Topic",
  short_title: "Topic 4",
  published: false,
  open: true,
  featured: true,
  short_desc:
    "<p>This topic is not published. Thus it is only visible to administrators. Notice that even though the topic is featured it does not appear in the navigation bar. Also, normal users can not collaborate on the topic even though it is open.</p>",
  desc:
    "<p>This topic is not published. Thus it is only visible to administrators. Notice that even though the topic is featured it does not appear in the navigation bar. Also, normal users can not collaborate on the topic even though it is open.</p>"
})
|> Repo.insert!()

Idea.changeset(%Idea{}, %{
  id: 1,
  title: "First Idea",
  desc:
    "This idea was premade and has a fake-rating of 4.3 (through 5 fake raters).",
  fake_raters: 5,
  fake_rating: 4.3
})
|> put_assoc(:topic, topic1)
|> put_assoc(:user, triparna)
|> Repo.insert!()

Idea.changeset(%Idea{}, %{
  id: 2,
  title: "Second Idea",
  desc: "This idea was premade without fake rating",
  fake_raters: 0,
  fake_rating: 4
})
|> put_assoc(:topic, topic1)
|> put_assoc(:user, alex)
|> Repo.insert!()
