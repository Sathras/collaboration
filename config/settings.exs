use Mix.Config

# General application configuration
config :collaboration,
  minTime: 10 * 60,               # minimal experiment time [sec]
  password: System.get_env("PASSWORD_DEFAULT"),   # admin user password,
  survey_link: "https://usf.az1.qualtrics.com/jfe/form/SV_cUdM8cbGDj6tnvf",
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
