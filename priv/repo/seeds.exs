# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#

import Ecto.Changeset

alias Collaboration.Repo
alias Collaboration.Coherence.User
alias Collaboration.Contributions.Topic
alias Collaboration.Contributions.Idea
alias Collaboration.Contributions.Comment

Collaboration.Repo.delete_all(Collaboration.Coherence.User)

# Admin Users
{:ok, admin1} =
  User.changeset(%User{}, %{
    name: "Alex (Admin)",
    email: "alex@fuchsberger.us",
    password: "password",
    password_confirmation: "password"
  })
  |> Repo.insert!()
  |> Coherence.ConfirmableService.confirm!()

{:ok, admin2} =
  User.changeset(%User{}, %{
    name: "GJ (Admin)",
    email: "gdevreede@usf.edu",
    password: "password",
    password_confirmation: "password"
  })
  |> Repo.insert!()
  |> Coherence.ConfirmableService.confirm!()

{:ok, admin3} =
  User.changeset(%User{}, %{
    name: "Triparna (Admin)",
    email: "tdevreede@usf.edu",
    password: "password",
    password_confirmation: "password"
  })
  |> Repo.insert!()
  |> Coherence.ConfirmableService.confirm!()

# make the following users admins:
User.changeset(admin1, %{admin: true}) |> Repo.update!()
User.changeset(admin2, %{admin: true}) |> Repo.update!()
User.changeset(admin3, %{admin: true}) |> Repo.update!()

# Problem Owner Users
{:ok, owner1} =
  User.changeset(%User{}, %{
    name: "Owner 1",
    email: "owner1@test.test",
    password: "password",
    password_confirmation: "password"
  })
  |> Repo.insert!()
  |> Coherence.ConfirmableService.confirm!()

{:ok, owner2} =
  User.changeset(%User{}, %{
    name: "Owner 2",
    email: "owner2@test.test",
    password: "password",
    password_confirmation: "password"
  })
  |> Repo.insert!()
  |> Coherence.ConfirmableService.confirm!()

{:ok, owner3} =
  User.changeset(%User{}, %{
    name: "Owner 3",
    email: "owner3@test.test",
    password: "password",
    password_confirmation: "password"
  })
  |> Repo.insert!()
  |> Coherence.ConfirmableService.confirm!()

# make the following users admins:
User.changeset(owner1, %{owner: true}) |> Repo.update!()
User.changeset(owner2, %{owner: true}) |> Repo.update!()
User.changeset(owner3, %{owner: true}) |> Repo.update!()

{:ok, cond1} =
  User.changeset(%User{}, %{
    name: "Condition 1 User",
    email: "cond1@test.test",
    password: "password",
    password_confirmation: "password"
  })
  |> Repo.insert!()
  |> Coherence.ConfirmableService.confirm!()

{:ok, cond2} =
  User.changeset(%User{}, %{
    name: "Condition 2 User",
    email: "cond2@test.com",
    password: "password",
    password_confirmation: "password"
  })
  |> Repo.insert!()
  |> Coherence.ConfirmableService.confirm!()

{:ok, cond3} =
  User.changeset(%User{}, %{
    name: "Condition 3 User",
    email: "cond3@test.com",
    password: "password",
    password_confirmation: "password"
  })
  |> Repo.insert!()
  |> Coherence.ConfirmableService.confirm!()

{:ok, cond4} =
  User.changeset(%User{}, %{
    name: "Condition 4 User",
    email: "cond4@test.com",
    password: "password",
    password_confirmation: "password"
  })
  |> Repo.insert!()
  |> Coherence.ConfirmableService.confirm!()

# specifiy condition for test users:
User.changeset(cond1, %{condition: 1}) |> Repo.update!()
User.changeset(cond2, %{condition: 2}) |> Repo.update!()
User.changeset(cond3, %{condition: 3}) |> Repo.update!()
User.changeset(cond4, %{condition: 4}) |> Repo.update!()

## add some sample topics
topic1 = Topic.changeset(%Topic{}, %{
  id: 1,
  title: "1. Topic (published, featured, open)",
  short_title: "Topic 1",
  published: true,
  open: true,
  featured: true,
  short_desc: "<p>This topic is open for editing and has been published and featured. Thus it appears in the navigation bar!</p>",
  desc: "<p>This topic is open for editing and has been published and featured. Thus it appears in the navigation bar!</p>"
})
|> Repo.insert!()

Topic.changeset(%Topic{}, %{
  id: 2,
  title: "2. Topic (published, closed, featured)",
  short_title: "Topic 2",
  published: true,
  open: false,
  featured: true,
  short_desc: "<p>This topic is featured and published. Thus it appears in the navigation bar. Since it is closed, however, normal users cannot add ideas, comments, likes and ratings.</p>",
  desc: "<p>This topic is featured and published. Thus it appears in the navigation bar. Since it is closed, however, normal users cannot add ideas, comments, likes and ratings.</p>"
})
|> Repo.insert!()

Topic.changeset(%Topic{}, %{
  id: 3,
  title: "3. Topic (published, open, not featured)",
  short_title: "Topic 3",
  published: true,
  open: true,
  featured: false,
  short_desc: "<p>This topic is not featured. Thus it only appears in the topic list.</p>",
  desc: "<p>This topic is not featured. Thus it only appears in the topic list.</p>"
})
|> Repo.insert!()

Topic.changeset(%Topic{}, %{
  id: 4,
  title: "4. Topic (not published, open, featured",
  short_title: "Topic 4",
  published: false,
  open: true,
  featured: true,
  short_desc: "<p>This topic is not published. Thus it is only visible to administrators. Notice that even though the topic is featured it does not appear in the navigation bar. Also, normal users can not collaborate on the topic even though it is open.</p>",
  desc: "<p>This topic is not published. Thus it is only visible to administrators. Notice that even though the topic is featured it does not appear in the navigation bar. Also, normal users can not collaborate on the topic even though it is open.</p>"
})
|> Repo.insert!()

idea1 = Idea.changeset(%Idea{}, %{
  id: 1,
  title: "First Idea",
  desc: "This idea was premade and has a fake-rating of 4.3 (through 5 fake raters). It was creaded by an Administrator and is therefore visible to all users",
  fake_raters: 5,
  fake_rating: 4.3
})
|> put_assoc(:topic, topic1)
|> put_assoc(:user, admin3)
|> Repo.insert!()

Idea.changeset(%Idea{}, %{
  id: 2,
  title: "Second Idea",
  desc: "This idea was premade without fake rating. It was created by a Problem Owner and is therefore also visible to all users.",
  fake_raters: 0,
  fake_rating: 4
})
|> put_assoc(:topic, topic1)
|> put_assoc(:user, owner2)
|> Repo.insert!()

Idea.changeset(%Idea{}, %{
  id: 3,
  title: "Third Idea (User 1)",
  desc: "This idea was premade without fake rating. It was created by a normal user and is thus only visible to him/her.",
  fake_raters: 0,
  fake_rating: 4
})
|> put_assoc(:topic, topic1)
|> put_assoc(:user, cond1)
|> Repo.insert!()

Idea.changeset(%Idea{}, %{
  id: 4,
  title: "Third Idea (User 2)",
  desc: "This idea was premade without fake rating. It was created by a normal user and is thus only visible to him/her.",
  fake_raters: 0,
  fake_rating: 4
})
|> put_assoc(:topic, topic1)
|> put_assoc(:user, cond2)
|> Repo.insert!()

Idea.changeset(%Idea{}, %{
  id: 5,
  title: "Third Idea (User 3)",
  desc: "This idea was premade without fake rating. It was created by a normal user and is thus only visible to him/her.",
  fake_raters: 0,
  fake_rating: 4
})
|> put_assoc(:topic, topic1)
|> put_assoc(:user, cond3)
|> Repo.insert!()

Idea.changeset(%Idea{}, %{
  id: 6,
  title: "Third Idea (User 4)",
  desc: "This idea was premade without fake rating. It was created by a normal user and is thus only visible to him/her.",
  fake_raters: 0,
  fake_rating: 4
})
|> put_assoc(:topic, topic1)
|> put_assoc(:user, cond4)
|> Repo.insert!()

# sample comments

Comment.changeset(%Comment{}, %{
  text: "Public comment by Admin in public idea with fake likes",
  fake_likes: 17
})
|> put_assoc(:idea, idea1)
|> put_assoc(:user, admin1)
|> Repo.insert!()

Comment.changeset(%Comment{}, %{
  text: "Public comment by Problem Owner in public idea with fake likes",
  fake_likes: 27
})
|> put_assoc(:idea, idea1)
|> put_assoc(:user, owner1)
|> Repo.insert!()

Comment.changeset(%Comment{}, %{
  text: "User comment by Condition 1 Testuser in public idea without fake likes (only visible to user)"
})
|> put_assoc(:idea, idea1)
|> put_assoc(:user, cond1)
|> Repo.insert!()

Comment.changeset(%Comment{}, %{
  text: "User comment by Condition 2 Testuser in public idea without fake likes (only visible to user)"
})
|> put_assoc(:idea, idea1)
|> put_assoc(:user, cond2)
|> Repo.insert!()

Comment.changeset(%Comment{}, %{
  text: "User comment by Condition 3 Testuser in public idea without fake likes (only visible to user)"
})
|> put_assoc(:idea, idea1)
|> put_assoc(:user, cond3)
|> Repo.insert!()

Comment.changeset(%Comment{}, %{
  text: "User comment by Condition 4 Testuser in public idea without fake likes (only visible to user)"
})
|> put_assoc(:idea, idea1)
|> put_assoc(:user, cond4)
|> Repo.insert!()