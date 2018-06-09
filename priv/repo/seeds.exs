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

# Admin Users
{:ok, admin}  = User.changeset(%User{}, %{ name: "USF", email: "admin@fuchsberger.us", password: "password", password_confirmation: "password" }) |> Repo.insert!() |> Coherence.ConfirmableService.confirm!()
{:ok, admin1} = User.changeset(%User{}, %{ name: "Alex", email: "alex@fuchsberger.us", password: "password", password_confirmation: "password" }) |> Repo.insert!() |> Coherence.ConfirmableService.confirm!()
{:ok, admin2} = User.changeset(%User{}, %{ name: "GJ", email: "gdevreede@usf.edu", password: "password", password_confirmation: "password" }) |> Repo.insert!() |> Coherence.ConfirmableService.confirm!()
{:ok, admin3} = User.changeset(%User{}, %{ name: "Triparna", email: "tdevreede@usf.edu", password: "password", password_confirmation: "password" }) |> Repo.insert!() |> Coherence.ConfirmableService.confirm!()

User.changeset(admin,  %{admin: true}) |> Repo.update!()
User.changeset(admin1, %{admin: true}) |> Repo.update!()
User.changeset(admin2, %{admin: true}) |> Repo.update!()
User.changeset(admin3, %{admin: true}) |> Repo.update!()

# PEER USERS
{:ok, peer1} = User.changeset(%User{}, %{ name: "Shonna. D", email: "peer1@test.test", password: "password", password_confirmation: "password" }) |> Repo.insert!() |> Coherence.ConfirmableService.confirm!()
{:ok, peer2} = User.changeset(%User{}, %{ name: "Derek. R", email: "peer2@test.test", password: "password", password_confirmation: "password" }) |> Repo.insert!() |> Coherence.ConfirmableService.confirm!()
{:ok, peer3} = User.changeset(%User{}, %{ name: "Payel. N", email: "peer3@test.test", password: "password", password_confirmation: "password" }) |> Repo.insert!() |> Coherence.ConfirmableService.confirm!()
{:ok, peer4} = User.changeset(%User{}, %{ name: "Megan. V", email: "peer4@test.test", password: "password", password_confirmation: "password" }) |> Repo.insert!() |> Coherence.ConfirmableService.confirm!()
{:ok, peer5} = User.changeset(%User{}, %{ name: "Tim. O", email: "peer5@test.test", password: "password", password_confirmation: "password" }) |> Repo.insert!() |> Coherence.ConfirmableService.confirm!()
{:ok, peer6} = User.changeset(%User{}, %{ name: "Lindsey K.", email: "peer6@test.test", password: "password", password_confirmation: "password" }) |> Repo.insert!() |> Coherence.ConfirmableService.confirm!()
{:ok, peer7} = User.changeset(%User{}, %{ name: "Jeff B.", email: "peer7@test.test", password: "password", password_confirmation: "password" }) |> Repo.insert!() |> Coherence.ConfirmableService.confirm!()
{:ok, peer8} = User.changeset(%User{}, %{ name: "Tina L.", email: "peer8@test.test", password: "password", password_confirmation: "password" }) |> Repo.insert!() |> Coherence.ConfirmableService.confirm!()
{:ok, peer9} = User.changeset(%User{}, %{ name: "Beth L.", email: "peer9@test.test", password: "password", password_confirmation: "password" }) |> Repo.insert!() |> Coherence.ConfirmableService.confirm!()
{:ok, peer10} = User.changeset(%User{}, %{ name: "Fahad K.", email: "peer10@test.test", password: "password", password_confirmation: "password" }) |> Repo.insert!() |> Coherence.ConfirmableService.confirm!()
{:ok, peer11} = User.changeset(%User{}, %{ name: "Bailey Y.", email: "peer11@test.test", password: "password", password_confirmation: "password" }) |> Repo.insert!() |> Coherence.ConfirmableService.confirm!()
{:ok, peer12} = User.changeset(%User{}, %{ name: "Rao P.", email: "peer12@test.test", password: "password", password_confirmation: "password" }) |> Repo.insert!() |> Coherence.ConfirmableService.confirm!()
{:ok, peer13} = User.changeset(%User{}, %{ name: "George O.", email: "peer13@test.test", password: "password", password_confirmation: "password" }) |> Repo.insert!() |> Coherence.ConfirmableService.confirm!()
{:ok, peer14} = User.changeset(%User{}, %{ name: "Kinsley R.", email: "peer14@test.test", password: "password", password_confirmation: "password" }) |> Repo.insert!() |> Coherence.ConfirmableService.confirm!()
{:ok, peer15} = User.changeset(%User{}, %{ name: "Bindi P.", email: "peer15@test.test", password: "password", password_confirmation: "password" }) |> Repo.insert!() |> Coherence.ConfirmableService.confirm!()

User.changeset(peer1,  %{peer: true}) |> Repo.update!()
User.changeset(peer2,  %{peer: true}) |> Repo.update!()
User.changeset(peer3,  %{peer: true}) |> Repo.update!()
User.changeset(peer4,  %{peer: true}) |> Repo.update!()
User.changeset(peer5,  %{peer: true}) |> Repo.update!()
User.changeset(peer6,  %{peer: true}) |> Repo.update!()
User.changeset(peer7,  %{peer: true}) |> Repo.update!()
User.changeset(peer8,  %{peer: true}) |> Repo.update!()
User.changeset(peer9,  %{peer: true}) |> Repo.update!()
User.changeset(peer10, %{peer: true}) |> Repo.update!()
User.changeset(peer11, %{peer: true}) |> Repo.update!()
User.changeset(peer12, %{peer: true}) |> Repo.update!()
User.changeset(peer13, %{peer: true}) |> Repo.update!()
User.changeset(peer14, %{peer: true}) |> Repo.update!()
User.changeset(peer15, %{peer: true}) |> Repo.update!()

# TESTUSERS
{:ok, cond1} = User.changeset(%User{}, %{ name: "Condition 1 User", email: "cond1@test.test", password: "password", password_confirmation: "password" }) |> Repo.insert!() |> Coherence.ConfirmableService.confirm!()
{:ok, cond2} = User.changeset(%User{}, %{ name: "Condition 2 User", email: "cond2@test.test", password: "password", password_confirmation: "password" }) |> Repo.insert!() |> Coherence.ConfirmableService.confirm!()
{:ok, cond3} = User.changeset(%User{}, %{ name: "Condition 3 User", email: "cond3@test.test", password: "password", password_confirmation: "password" }) |> Repo.insert!() |> Coherence.ConfirmableService.confirm!()
{:ok, cond4} = User.changeset(%User{}, %{ name: "Condition 4 User", email: "cond4@test.test", password: "password", password_confirmation: "password" }) |> Repo.insert!() |> Coherence.ConfirmableService.confirm!()

User.changeset(cond1, %{condition: 1}) |> Repo.update!()
User.changeset(cond2, %{condition: 2}) |> Repo.update!()
User.changeset(cond3, %{condition: 3}) |> Repo.update!()
User.changeset(cond4, %{condition: 4}) |> Repo.update!()

## SAMPLE TOPICS
topic1 = Topic.changeset(%Topic{}, %{
  title: "What are the solutions to illegal immigration in America?",
  short_title: "Illegal Imigration",
  published: true,
  featured: true,
  short_desc: "<p>With over 11 million immigrants in the United States
    illegally (as of 2012), the issue of illegal immigration continues to
    divide Americans.</p>",
  desc: "
    <p>With over 11 million immigrants in the United States illegally (as of
      2012), the issue of illegal immigration continues to divide Americans.</p>
    <p>Some people say that illegal immigration benefits the US economy
      through additional tax revenue and expansion of the low-cost labor pool.
      Opponents of illegal immigration say that people who break the law
      by crossing the US border without proper documentation or by overstaying
      their visas should be deported and not rewarded with a path to citizenship
      and access to social services.</p>"
}) |> Repo.insert!()

Topic.changeset(%Topic{}, %{
  title: "2. Topic (published, not featured)",
  short_title: "Topic 3",
  published: true,
  featured: false,
  short_desc: "<p>This topic is not featured. Thus it only appears in the topic list.</p>",
  desc: "<p>This topic is not featured. Thus it only appears in the topic list.</p>"
}) |> Repo.insert!()

Topic.changeset(%Topic{}, %{
  title: "3. Topic (not published, featured)",
  short_title: "Topic 4",
  published: false,
  featured: true,
  short_desc: "<p>This topic is not published. Thus it is only visible to
    administrators. Notice that even though the topic is featured it does not
    appear in the navigation bar. Normal users can not collaborate.</p>",
  desc: "<p>This topic is not published. Thus it is only visible to administrators.
    Notice that even though the topic is featured it does not appear in the
    navigation bar. Normal users can not collaborate.</p>"
}) |> Repo.insert!()

idea1 = Idea.changeset(%Idea{}, %{
  text: "I strongly advocate for immigration reform that focuses on enforcement and upholding the rule of law, including elimination of enforcement waivers that have been abused by previous and current Administrations. To be clear, any immigration reform proposal must first guarantee that our immigration laws are enforced both at the border and within the United States. I remain opposed to amnesty, as I always have been. I do not support a special pathway to citizenship that rewards those who have broken our immigration laws.",
  fake_raters: 5,
  fake_rating: 4.3
})
|> put_assoc(:topic, topic1)
|> put_assoc(:user, peer1)
|> Repo.insert!()

idea2 = Idea.changeset(%Idea{}, %{
  text: "It starts with enforcing the rule of law. But you need to have a vibrant, legal immigration system. Legal immigration is America… I think you could have a pathway to legal status. That's been what I have proposed in the past is a pay--a way to make amends with the law, effectively go on probation and earn your way to legal status, but not to citizenship.",
  fake_raters: 0,
  fake_rating: 4
})
|> put_assoc(:topic, topic1)
|> put_assoc(:user, peer2)
|> Repo.insert!()

idea3 = Idea.changeset(%Idea{}, %{
  text: "I support a comprehensive immigration reform--not just because it is the right thing to do, but because it strengthens families, our economy, and our country. Congress must pass comprehensive immigration reform that provides a path to citizenship, treats every person with dignity, upholds the rule of law, protects our borders and national security, and brings millions of hardworking people into the formal economy",
  fake_raters: 0,
  fake_rating: 4
})
|> put_assoc(:topic, topic1)
|> put_assoc(:user, peer3)
|> Repo.insert!()

idea4 = Idea.changeset(%Idea{}, %{
  text: "A more pragmatic solution would be to offer a path to legalization that stops short of citizenship. That would meet the humanitarian imperative to keep families together. But it would also hold those who have violated immigration laws accountable for their actions. This would apply only to undocumented workers who were of legal age when they entered the United States; those who were not of legal age should be given a citizenship path identical to the one that is available to legal immigrants.",
  fake_raters: 0,
  fake_rating: 4
})
|> put_assoc(:topic, topic1)
|> put_assoc(:user, peer4)
|> Repo.insert!()

idea5 = Idea.changeset(%Idea{}, %{
  text: "It is no great secret that across the United States undocumented workers perform a critical role in our economy. They harvest and process our food and it is no exaggeration to say that, without them, food production in the United States would significantly decline. Undocumented workers build many of our homes, cook our meals, maintain our landscapes. We even entrust undocumented workers with that which we hold most dear – our children...",
  fake_raters: 0,
  fake_rating: 4
})
|> put_assoc(:topic, topic1)
|> put_assoc(:user, peer5)
|> Repo.insert!()

# # sample comments

Comment.changeset(%Comment{}, %{
  text: "Hmm… that is an interesting point. Thank you for bringing that up.",
  fake_likes: 17
})
|> put_assoc(:idea, idea1)
|> put_assoc(:user, admin)
|> Repo.insert!()

Comment.changeset(%Comment{}, %{
  text: "I do not agree – but everyone is entitled to their opinion."
})
|> put_assoc(:idea, idea1)
|> put_assoc(:user, peer6)
|> Repo.insert!()

Comment.changeset(%Comment{}, %{
  text: "That is an excellent point. We love to hear more about that.",
  fake_likes: 4
})
|> put_assoc(:idea, idea2)
|> put_assoc(:user, admin)
|> Repo.insert!()

Comment.changeset(%Comment{}, %{
  text: "Exactly. I know what you mean!"
})
|> put_assoc(:idea, idea2)
|> put_assoc(:user, peer7)
|> Repo.insert!()

Comment.changeset(%Comment{}, %{
  text: "We love your passion. Can you elaborate on this a bit more?"
})
|> put_assoc(:idea, idea3)
|> put_assoc(:user, admin)
|> Repo.insert!()

Comment.changeset(%Comment{}, %{
  text: "It is not enough to want it, someone has to come up with a plan."
})
|> put_assoc(:idea, idea3)
|> put_assoc(:user, peer8)
|> Repo.insert!()

Comment.changeset(%Comment{}, %{
  text: "That is a very interesting perspective. Thank you."
})
|> put_assoc(:idea, idea4)
|> put_assoc(:user, admin)
|> Repo.insert!()

Comment.changeset(%Comment{}, %{
  text: "Children are indeed important. Thank you Tim. We would love to hear what other have to say about that."
})
|> put_assoc(:idea, idea5)
|> put_assoc(:user, admin)
|> Repo.insert!()

Comment.changeset(%Comment{}, %{
  text: "But we do take must take care of our own too – especially our children."
})
|> put_assoc(:idea, idea5)
|> put_assoc(:user, peer9)
|> Repo.insert!()