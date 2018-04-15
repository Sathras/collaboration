use Bootleg.Config

# Configure the following roles to match your environment.
# `build` defines what remote server your distillery release should be built on.
#
# Some available options are:
#  - `user`: ssh username to use for SSH authentication to the role's hosts
#  - `password`: password to be used for SSH authentication
#  - `identity`: local path to an identity file that will be used for SSH authentication instead of a password
#  - `workspace`: remote file system path to be used for building and deploying this Elixir project

role :build, "35.196.90.42", user: "deploy", workspace: "builds/collaboration"
role :app,   "35.196.90.42", user: "deploy", workspace: "apps/collaboration"

