use Bootleg.Config

# Configure the following roles to match your environment.
# `build` defines what remote server your distillery release should be built on.
# `app` defines what remote servers your distillery release should be deployed and managed on.
#
# Some available options are:
#  - `user`: ssh username to use for SSH authentication to the role's hosts
#  - `password`: password to be used for SSH authentication
#  - `identity`: local path to an identity file that will be used for SSH authentication instead of a password
#  - `workspace`: remote file system path to be used for building and deploying this Elixir project

role :build, "35.196.90.42", user: "deploy", workspace: "builds/collaboration"
role :app,   "35.196.90.42", user: "deploy", workspace: "apps/collaboration"

# Phoenix has some extra build steps which can be defined as task after the compile step runs.
#
# Uncomment the following task definition if this is a Phoenix application. To learn more about
# hooks and adding additional behavior to your deploy workflow, please refer to the bootleg
# README which can be found at https://github.com/labzero/bootleg/blob/master/README.md

after_task :compile do
  mix_env = Keyword.get(config(), :mix_env, "prod")

  remote :build do
    "[ -f package.json ] && npm install || true"
    "[ -f brunch-config.js ] && [ -d node_modules ] && ./node_modules/brunch/bin/brunch b -p || true"
    "[ -d deps/phoenix ] && MIX_ENV=#{mix_env} mix phoenix.digest || true"
  end
end
