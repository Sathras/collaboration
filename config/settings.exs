use Mix.Config

# General application configuration
config :collaboration,

  # suggested experiment time [sec]
  minTime: 10 * 60,

  # survey link after completing / aborting the experiment
  survey_link: "https://usf.az1.qualtrics.com/jfe/form/SV_cUdM8cbGDj6tnvf",

  # bot likes comments after a specified delay
  # Example: 5 => [{12, 530}, {13, 180}]
  # a user in condition 5 will observe a like for comment #12 after 530 seconds,
  # and another one for comment #13 after 180 seconds since start of experiment.
  delayed_likes: %{
    1 => [],
    2 => [],
    3 => [],
    4 => [],
    5 => [{ 12, 530 }, { 13, 180 }, { 18, 90 }],
    6 => [{  1, 530 }, {  2, 180 }, {  6, 90 }],
    7 => [{ 12, 530 }, { 13, 180 }, { 18, 90 }],
    8 => [{  1, 530 }, {  2, 180 }, {  6, 90 }]
  }
