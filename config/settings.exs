use Mix.Config

# General application configuration
config :collaboration,

  # if false than an experiment can only be started once with a given user id
  allow_multiple_submissions?: true,

  # suggested experiment time [sec]
  minTime: 10 * 60,

  # survey link after completing / aborting the experiment
  survey_link: "https://usf.az1.qualtrics.com/jfe/form/SV_cUdM8cbGDj6tnvf",

  # bot likes comments after a specified delay
  # make sure they are ordered with lowest delay first
  # Example: 5 => [{12, 530}, {13, 180}]
  # a user in condition 5 will observe a like for comment #12 after 530 seconds,
  # and another one for comment #13 after 180 seconds since start of experiment.
  delayed_likes: %{
    5 => [{ 18, 90 }, { 13, 180 }, { 12, 530 }],
    6 => [{  6, 90 }, {  2, 180 }, {  1, 530 }],
    7 => [{ 18, 90 }, { 13, 180 }, { 12, 530 }],
    8 => [{  6, 90 }, {  2, 180 }, {  1, 530 }]
  },

  idea_response_ids: %{
    3 => [24],
    4 => [25],
    7 => [26, 36],
    8 => [27, 37]
  },

  comment_response_ids: %{
    3 => [28],
    4 => [29],
    7 => [30, 32, 34],
    8 => [31, 33, 35]
  }
