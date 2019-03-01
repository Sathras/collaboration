defmodule Collaboration.Seeder do
  @moduledoc """
  Provides functions to populate the database with users, topics, ideas, ...
  you can run this file via: $ mix run priv/repo/seeds.exs
  """
  import Ecto.Changeset, only: [put_assoc: 3]
  import Collaboration.Accounts

  alias Collaboration.Repo
  alias Collaboration.Contributions.{ Topic, Idea, Comment }

  # set a default password for users with credentials
  @password Application.fetch_env!(:collaboration, :password)

  def init do

    # create some peer users first (have no login)
    u1 = user "chemistrynerd1994"
    u2 = user "islandthyme"
    u3 = user "JF0909"
    u4 = user "BetsyB"
    u5 = user "Muma"
    u6 = user "3-DMan"
    u7 = user "Vans"
    u8 = user "JustBrad"
    u9 = user "i_v_a_n"
    u10 = user "mattncheese"

    # create an admin user (able to login)
    user "Admin", "admin"

    t1 = topic %{
      title: "How can USF improve its Parking and Transportation Services?",
      featured: true,
      desc: "
        <p>Parking and Transportation Services at the University of South Florida Tampa Campus is the division responsible for the overall management of the Bull Runner Transit System and parking facilities and services. At the division we have applied different approaches and solutions to ease commute to and within USF for students, faculty, and visitors. Despite the efforts to improve parking and transportation in past years, we acknowledge the need for innovative ideas and solutions to improve our services. </p>
        <p>We understand how important and critical its services are to the USF community and would like to hear your ideas to improve their services.
        As you are a member of the USF community, we are eager to listen to your perspective. We plan to integrate your ideas in our plans and
        operations. Please share your ideas, comments, and thoughts on how to improve and offer new parking and transportation services. More you
        share, greater the chances that your idea will be incorporated. For more information about our services, please feel free to visit our online page.</p>"
    }

    i1 = idea %{
      text: "I think that the parking situation has been improving over the past semesters. I would say that we should get at least another parking garage so that more parking is available.",
      fake_raters: 9,
      fake_rating: 4.1,
      c2: -3600, c4: -3600, c6: -3600, c8: -3600
    }, t1, u1

    i2 = idea %{
      text: "I like to park far away from my building and walk but I know that so many like to park closer to their building. Maybe we can promote campus walking more and even setup walking competition with Fitbit or other trackers so others might get more excited to park far away and walk instead.",
      fake_raters: 12,
      fake_rating: 4.3,
      c2: -3600, c4: -3600, c6: -3600, c8: -3600
    }, t1, u2

    i3 = idea %{
      text: "Parking availability has room for improvement. Maybe we can consider reducing some of the pay-by-space spots and use that space for students to park instead?",
      fake_raters: 6,
      fake_rating: 4.6,
      c2: -1800, c4: -1800, c6: -1800, c8: -1800
    }, t1, u3

    i4 = idea %{
      text: "I am glad they are doing something. Its awesome that there is a first step. One suggestion that I have that may be helpful is to invite some of these electric scooter companies to bring their scooters to campus. I was in LA this past summer for an internship and used these scooter a couple times. I thought it was fun and convenient. It adds to the fun of being a college student on campus.",
      fake_raters: 8,
      fake_rating: 3.9,
      c2: -600, c4: -600, c6: -600, c8: -600
    }, t1, u4

    i5 = idea %{
      text: "I actually really like the bulltracker app and I believe that it is a great effort. Kudos to USF for doing that! I use it daily for my commute to the University. Only suggestion for improvement I have to this awesome service is  to add alerts for when drivers are about to change shift. That helps us to time our bus rides more efficiently.",
      c2: 300, c4: 300, c6: 300, c8: 300
    }, t1, u5

    i6 = idea %{
      text: "I am glad they are doing something. Its awesome that there is a first step. One suggestion that I have that may be helpful is to invite some of these electric scooter companies to bring their scooters to campus. I was in LA this past summer for an internship and used these scooter a couple times. I thought it was fun and convenient. It adds to the fun of being a college student on campus.",
      fake_raters: 9,
      fake_rating: 4.1,
      c1: -3600, c3: -3600, c5: -3600, c7: -3600
    }, t1, u6

    i7 = idea %{
      text: "Is it just me or is everyone is just lazy? Just park far away from my building and walk. Why don’t you push people toward walking by having competitions with Fitbit or other trackers so others might get up from their couches and start to walk instead. They can actually loss weight this way instead of complaining!",
      fake_raters: 12,
      fake_rating: 4.3,
      c1: -3600, c3: -3600, c5: -3600, c7: -3600
    }, t1, u7

    i8 = idea %{
      text: "I hate how parking spaces are limited for students. Parking availability definitely needs to be addressed right now! It is silly that they have so many pay-by-space parkings available instead of letting us park! Money is wasted into unnecessary things. Parking problem needs to be FIXED if they want us to study here!",
      fake_raters: 6,
      fake_rating: 4.6,
      c1: -1800, c3: -1800, c5: -1800, c7: -1800
    }, t1, u8

    i9 = idea %{
      text: "To me walking is just pain especially when I have to go to two classes that are in two different buildings miles from each other. They are so uninventive when it comes to coming up with solutions to problems! For example, I was in LA this past summer for an internship and used these scooter a couple times. That worked out well for me. Why don’t they do something sensible like that and invite some electric scooter companies to bring their scooters to campus?",
      fake_raters: 8,
      fake_rating: 3.9,
      c1: -600, c3: -600, c5: -600, c7: -600
    }, t1, u9

    i10 = idea %{
      text: "You know what’s the worst app, yup you’re correct it’s the bulltracker app! What were they thinking when they made it? at least they can start by alerting us when drivers are about to change shift and making the app less glitchy. Then I am not standing at the bus stop forever without knowing when the next bus will come!",
      c1: 300, c3: 300, c5: 300, c7: 300
    }, t1, u10

    # c1
    comment %{
      text: "I totally agree with you. The Bulltracker in the app needs improvement but we are moving in the right direction. Indeed kudos!",
      c6: 500, c8: 500
    }, i5, u3

    #c2
    comment %{
      text: "That is a great idea too! One more thing that occurs to me. How about if we offer student passes for free or at a better rate? They would be so encouraged to park further and relieve some of the congestion. Win-win for all!",
      c2: -1800, c4: -1800, c6: -1800, c8: -1800
    }, i1, u4

    # c3
    comment %{
      text: "This a fantastic idea. Walking will even benefit so many in terms of health! I actually love to walk and its making lemons out of lemonade.",
      fake_likes: 3,
      c2: -600, c4: -600, c6: -600, c8: -600
    }, i2, u3

    # c4
    comment %{
      text: "Interesting!",
      c6: 90, c8: 90
    }, i4, u2

    # c5
    comment %{
      text: "I typically arrive a bit early and I always find a spot to park. So, it really is a matter of some good planning and common sense.",
      fake_likes: 5,
      c2: -1200, c4: -1200, c6: -1200, c8: -1200
    }, i2, u7

    # c6
    comment %{
      text: "I've lived in the university lake apartments for the past 2 years and have been able to get away with not buying a pass. I bike to class and the REC center, only takes about 15 minutes to get from one corner of campus to the other. This would be a good alternative if they get them to come. They have great options for those of us who are willing to take it!",
      c2: 60, c4: 60, c6: 60, c8: 60
    }, i4, u8

    # c7
    comment %{
      text: "The walk idea sounds nice especially in beautiful weather. Tampa has gorgeous weather most of the days any way – especially compared to where I come from! lol",
      c6: 180, c8: 180
    }, i2, u6

    # c8
    comment %{
      text: "There’s a construction at parking lot 16 nearby. I think that we’re moving into the right direction! All good things happen to those who wait! lol",
      c6: 300, c8: 300
    }, i1, u9

    # c9
    comment %{
      text: "You can easily park by the Sundome then longboard over to your class in a minute. It is so much fun too!!",
      c6: 420, c8: 420
    }, i3, u6

    # c10
    comment %{
      text: "Parking is fine! That parking lot east of the sundome is almost always available :)",
      c6: 480, c8: 480
    }, i3, u7

    # c11
    comment %{
      text: "It seems to me that a lot of reserved spots are not being used. Maybe we should work out a better layout of designated parking spaces for students, employees and visitors. We can make the best of what we have until new spots are created.",
      c6: 540, c8: 540
    }, i3, u8

    # c12
    comment %{
      text: "So true! The Bulltracker in the app is worthless. Looked at arrival time, F bus in 10 minutes. Refresh it 1 minute later, F bus arriving. The times displayed are worthless, especially when a bus could show up as arriving, but actually be heading to the garage or the driver could be going on break. They should either fix it or scrap it!",
      c5: 500, c7: 500
    }, i10, u1

    # c13
    comment %{
      text: "The fact that students have to drive around for hours with not enough parking for everyone is ridiculous especially if you pay for a parking pass! Parking passes are robbing students especially with limited parking spots. There are students facing financial issues or can’t afford it in general and the university wants us to pay more for passes. I have been late to class so many times because of their incompetence!",
      fake_likes: 2,
      c1: -1800, c3: -1800, c5: -1800, c7: -1800
    }, i6, u2

    # c14
    comment %{
      text: "The problem is everyone wants to park close to the building. No matter what, they are going to. If you park in a lot further away, you can walk ...yes, I said walk to your building. Life is a tougher in the real-world folks. It is plain dumb to complain about using your legs!",
      fake_likes: 3,
      c1: -600, c3: -600, c5: -600, c7: -600
    }, i7, u3

    # c15
    comment %{
      text: "This is just dumb",
      c5: 90, c7: 90
    }, i9, u4

    # c16
    comment %{
      text: "I arrived at 12pm one time on a Thursday and I could not find one parking spot. For how much I spend to go to college/parking pass, it's ridiculous that I don't have a place to park. Can’t they see how frustrated we are!",
      fake_likes: 5,
      c1: -1200, c3: -1200, c5: -1200, c7: -1200
    }, i8, u5

    # c17
    comment %{
      text: "Or you can just buy your own bike instead of getting ripped off by these companies! These companies are just looking to charge atrocious amounts of money for a simple convenience.",
      c1: 60, c3: 60, c5: 60, c7: 60
    }, i9, u1

    # c18
    comment %{
      text: "Plz that’s just ridiculous!  It can get quite hot and uncomfortable sometimes which makes walking a nightmare. The last thing we want is to get a heatstroke! Nonsensical ideas is what will get us all into trouble!",
      c5: 180, c7: 180
    }, i7, u2

    # c19
    comment %{
      text: "Parking garages at USF just suck! There’s a construction at parking lot 16 nearby. Ironically, they expanded the parking there only to shortly after close 1/3 of it for god knows what.  I am appalled at their terrible lack of planning!",
      c5: 300, c7: 300
    }, i6, u3

    # c19
    comment %{
      text: "It’s 50/50 if I ever get a timely spot, and that’s because I stalk walking students waiting for someone to leave, which is a crappy position to be in for both the walker and driver. I just don’t understand why they have to be so inefficient in terms of creating parking spaces for us!",
      c5: 420, c7: 420
    }, i8, u4

    # c20
    comment %{
      text: "USF parking is just a total disaster! :’(",
      c5: 480, c7: 480
    }, i6, u5

    # c21
    comment %{
      text: "It seems to me that a lot of reserved spots are not being used while so many S permit holders are unable to find spots while those remain vacant in front of them which is just DISGUSTING!! I think the student body and parking services should meet and work out a layout of designated parking spaces for students, employees and visitors that  is actually not nonsense!",
      c5: 540, c7: 540
    }, i8, u6

    # c22
    comment %{
      text: "It seems to me that a lot of reserved spots are not being used while so many S permit holders are unable to find spots while those remain vacant in front of them which is just DISGUSTING!! I think the student body and parking services should meet and work out a layout of designated parking spaces for students, employees and visitors that  is actually not nonsense!",
      c5: 540, c7: 540
    }, i8, u6

    # bot-to-user comments
    comment %{ text: "that’s crazy!", c3: 40 }, u1 # 24
    comment %{ text: "What did I just read?", c3: 120 }, u3 # 25
    comment %{ text: "Bingo!", c3: 40 }, u6 # 26
    comment %{ text: "100% agree", c3: 120 }, u6 # 27
    comment %{ text: "you just won the worst idea award!", c7: 40 }, u7 # 28
    comment %{ text: "NOPE NOPE NOPE", c7: 400 }, u3 # 29
    comment %{ text: "This is just dumb", c7: 120 }, u2 # 30
    comment %{ text: "Feels bad man", c7: 200 }, u4 # 31
    comment %{ text: "Doesn’t make sense!", c7: 220 }, u5 # 32
    comment %{ text: "Added points for that idea!", c8: 40 }, u8 # 33
    comment %{ text: "hire this dude!", c8: 400 }, u10 # 34
    comment %{ text: "Sounds interesting!", c8: 120 }, u9 # 35
    comment %{ text: "well said", c8: 200 }, u6 # 36
    comment %{ text: "I like this!", c8: 220 }, u7 # 37
  end

  # all users created here will be peer users / admins
  defp user(name) do
    register_user! %{ name: name }
  end

  defp user(name, username) do
    register_user! %{
      name: name,
      credential: %{ username: username, password: @password }
    }
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

  # used for bot-to-user comments (do not belong to a specific idea)
  defp comment(params, user) do
    Comment.changeset(%Comment{}, params)
    |> put_assoc(:user, user)
    |> Repo.insert!()
  end
end

Collaboration.Seeder.init()
