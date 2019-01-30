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
    # peer users will have the following email: <id>@peer
    p1 = user "Shonna D.", "1@peer"
    user "Derek R.", "2@peer"
    user "Payel N.", "3@peer"
    user "Megan V.", "4@peer"
    user "Tim O.", "5@peer"
    user "Lindsey K.", "6@peer"
    user "Jeff B.", "7@peer"
    user "Tina L.", "8@peer"
    user "Beth L.", "9@peer"
    user "Fahad K.", "10@peer"
    user "Bailey Y.", "11@peer"
    user "Rao P.", "12@peer"
    user "George O.", "13@peer"
    user "Kinsley R.", "14@peer"
    user "Bindi P.", "15@peer"

    # admin users will have a real email instead of an identifier:
    user "USF", "admin@fuchsberger.us"
    user "Alex", "alex@fuchsberger.us"
    user "Naif", "naifalawi@mail.usf.edu"
    user "Triparna", "tdevreede@usf.edu"
    user "GJ", "gdevreede@usf.edu"

    t1 = topic %{
      title: "What are the solutions to illegal immigration in America?",
      short_title: "Illegal Imigration",
      visible: 1,
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

    topic %{
      title: "2. Topic (published, not featured)",
      short_title: "Topic 3",
      visible: 2,
      featured: false,
      short_desc: "<p>This topic is not featured. Thus it only appears in the topic list.</p>",
      desc: "<p>This topic is not featured. Thus it only appears in the topic list.</p>"
    }

    idea %{
      text: "I strongly advocate for immigration reform that focuses on enforcement and upholding the rule of law, including elimination of enforcement waivers that have been abused by previous and current Administrations. To be clear, any immigration reform proposal must first guarantee that our immigration laws are enforced both at the border and within the United States. I remain opposed to amnesty, as I always have been. I do not support a special pathway to citizenship that rewards those who have broken our immigration laws.",
      fake_raters: 5,
      fake_rating: 4.3
    }, t1, p1

  end

  defp user(name, email) do
    User.changeset(%User{}, %{ name: name, email: email }) |> Repo.insert!()
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

  # defp comment(params, idea, user) do
  #   Comment.changeset(%Comment{}, params)
  #   |> put_assoc(:idea, idea)
  #   |> put_assoc(:user, user)
  #   |> Repo.insert!()
  # end
end

Collaboration.Seeder.init()
