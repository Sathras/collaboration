defmodule Collaboration.Seeder do
  @moduledoc """
  Provides functions to populate the database with users, topics, ideas, ...
  you can run this file via: $ mix run priv/repo/seeds.exs
  """
  import Ecto.Changeset, only: [put_assoc: 3]
  alias Collaboration.Repo
  alias Collaboration.Coherence.User
  alias Collaboration.Contributions.{ Topic, Idea, Comment }

  def init do
    admin "USF", "admin@fuchsberger.us"
    admin "Alex", "alex@fuchsberger.us"
    admin "Naif", "naifalawi@mail.usf.edu"
    admin "Triparna", "tdevreede@usf.edu"
    admin "GJ", "gdevreede@usf.edu"

    p1 = peer "Shonna D.", 1
    p2 = peer "Derek R.", 2
    p3 = peer "Payel N.", 3
    p4 = peer "Megan V.", 4
    p5 = peer "Tim O.", 5
    p6 = peer "Lindsey K.", 6
    p7 = peer "Jeff B.", 7
    p8 = peer "Tina L.", 8
    p9 = peer "Beth L.", 9
    p10 = peer "Fahad K.", 10
    p11 = peer "Bailey Y.", 11
    p12 = peer "Rao P.", 12
    p13 = peer "George O.", 13
    p14 = peer "Kinsley R.", 14
    p15 = peer "Bindi P.", 15

    test "Test 1", 1
    test "Test 2", 2
    test "Test 3", 3
    test "Test 4", 4
    test "Test 5", 5
    test "Test 6", 6
    test "Test 7", 7
    test "Test 8", 8

    t1 = topic %{
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
    }

    t2 = topic %{
      title: "2. Topic (published, not featured)",
      short_title: "Topic 3",
      published: true,
      featured: false,
      short_desc: "<p>This topic is not featured. Thus it only appears in the topic list.</p>",
      desc: "<p>This topic is not featured. Thus it only appears in the topic list.</p>"
    }

    t3 = topic %{
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
    }


    i1 = idea %{
      text: "I strongly advocate for immigration reform that focuses on enforcement and upholding the rule of law, including elimination of enforcement waivers that have been abused by previous and current Administrations. To be clear, any immigration reform proposal must first guarantee that our immigration laws are enforced both at the border and within the United States. I remain opposed to amnesty, as I always have been. I do not support a special pathway to citizenship that rewards those who have broken our immigration laws.",
      fake_raters: 5,
      fake_rating: 4.3
    }, t1, p1

  end

  defp admin(name, email) do
    User.changeset(%User{}, %{ name: name, email: email }) |> Repo.insert!()
  end

  defp peer(name, peer_id) do
    User.changeset(%User{}, %{ name: name, peer: peer_id }) |> Repo.insert!()
  end

  defp test(name, condition) do
    User.changeset(%User{}, %{ name: name, condition: condition })
    |> Repo.insert!()
  end

  defp topic(params) do
    Topic.changeset(%Topic{}, params) |> Repo.insert!()
  end

  defp idea(params, topic, user) do
    Idea.changeset(%Idea{}, params)
    |> put_assoc(:topic, topic)
    |> put_assoc(:user, user)
    |> Repo.insert!()
  end

  defp comment(params, idea, user) do
    Comment.changeset(%Comment{}, params)
    |> put_assoc(:idea, idea)
    |> put_assoc(:user, user)
    |> Repo.insert!()
  end
end

Collaboration.Seeder.init()
