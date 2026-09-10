#!/usr/bin/env bats
# Behaviour layer: does each git alias do what it says, end to end, against
# a throwaway repository that includes this repo's real .gitaliases? Static
# analysis (the shellcheck CI step) catches bad shell; this file catches an
# alias that lints clean and does the wrong thing anyway.

load helpers/common

# Creates a throwaway repository at $ALIAS_REPO with this repo's real
# .gitaliases included and one seeded commit, so aliases that need a HEAD
# have one to act on. teardown() removes it, and $ALIAS_REMOTE when a test
# sets one.
#
# GIT_CONFIG_GLOBAL/_SYSTEM point at /dev/null so the developer's own
# ~/.gitconfig can't leak an alias of the same name into these tests --
# aliases here resolve only from $ALIAS_REPO's local config.
setup() {
  export GIT_CONFIG_GLOBAL=/dev/null
  export GIT_CONFIG_SYSTEM=/dev/null

  ALIAS_REPO="$(mktemp -d)"
  git -C "$ALIAS_REPO" init -q -b main
  git -C "$ALIAS_REPO" config --local include.path "$REPO_ROOT/.gitaliases"
  git -C "$ALIAS_REPO" -c user.email=test@test -c user.name=test \
    commit -q --allow-empty -m init
  ALIAS_REMOTE=""
}

teardown() {
  if [ -n "$ALIAS_REPO" ]; then rm -rf "$ALIAS_REPO"; fi
  if [ -n "$ALIAS_REMOTE" ]; then rm -rf "$ALIAS_REMOTE"; fi
}

@test "the fixture repo has .gitaliases included and a commit to act on" {
  run git -C "$ALIAS_REPO" config --get include.path
  [ "$status" -eq 0 ]
  [ "$output" = "$REPO_ROOT/.gitaliases" ]

  run git -C "$ALIAS_REPO" rev-parse HEAD
  [ "$status" -eq 0 ]
}

@test "the cc git alias resolves end to end via the [pretty] custom format" {
  run git -C "$ALIAS_REPO" cc init
  [ "$status" -eq 0 ]
}

@test "the cm git alias finds a commit by its message" {
  git -C "$ALIAS_REPO" -c user.email=test@test -c user.name=test \
    commit -q --allow-empty -m "widget: add frobnicator"

  run git -C "$ALIAS_REPO" cm frobnicator
  [ "$status" -eq 0 ]
  [[ "$output" == *"widget: add frobnicator"* ]]
}

@test "the lrb git alias lists origin's heads with no argument" {
  ALIAS_REMOTE="$(mktemp -d)"
  git init -q --bare "$ALIAS_REMOTE"
  git -C "$ALIAS_REPO" remote add origin "$ALIAS_REMOTE"
  git -C "$ALIAS_REPO" push -q origin main

  run git -C "$ALIAS_REPO" lrb
  [ "$status" -eq 0 ]
  [[ "$output" == *"refs/heads/main"* ]]
}

@test "the lrb git alias lists an explicit remote's heads" {
  ALIAS_REMOTE="$(mktemp -d)"
  git init -q --bare "$ALIAS_REMOTE"
  git -C "$ALIAS_REPO" remote add upstream "$ALIAS_REMOTE"
  git -C "$ALIAS_REPO" push -q upstream main

  run git -C "$ALIAS_REPO" lrb upstream
  [ "$status" -eq 0 ]
  [[ "$output" == *"refs/heads/main"* ]]
}

@test "the get git alias fetches and checks out a branch from origin" {
  ALIAS_REMOTE="$(mktemp -d)"
  git init -q --bare "$ALIAS_REMOTE"
  git -C "$ALIAS_REPO" remote add origin "$ALIAS_REMOTE"
  git -C "$ALIAS_REPO" push -q origin main
  git -C "$ALIAS_REPO" push -q origin main:feature

  run git -C "$ALIAS_REPO" get feature
  [ "$status" -eq 0 ]

  current="$(git -C "$ALIAS_REPO" symbolic-ref --short HEAD)"
  [ "$current" = "feature" ]
}

# git rejects a literal ref name containing a space everywhere (branch
# creation, remote advertisement), so this can't be proven by checking one
# out. Instead it asks for a pathspec that doesn't exist and reads the
# quoting off checkout's own error: one "pathspec 'does not exist'" means
# $1 arrived whole; three single-word pathspec errors mean it didn't.
@test "the get git alias treats an argument containing a space as one value" {
  run git -C "$ALIAS_REPO" get "does not exist"
  [ "$status" -ne 0 ]
  [[ "$output" == *"pathspec 'does not exist' did not match"* ]]
  [[ "$output" != *"pathspec 'does' did not match"* ]]
}
