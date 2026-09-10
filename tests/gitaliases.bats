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
setup() {
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
