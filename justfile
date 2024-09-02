set unstable := true
set dotenv-path := 'builder-env'

# Tasks for this project, e.g. test and coverage
mod inner 'lib'

# build with zig
mod zig 'mods/zig'
mod podman 'mods/podman'
mod github 'mods/github'
