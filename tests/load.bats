#!/usr/bin/env bats
# Layer 1: does each tool actually accept its config? No isolation needed —
# these just read files, they don't touch any running instance of the tool.

load helpers/common

setup() {
  TMUX_SOCKET="bats-$$"
  TMP_REPO=""
}

teardown() {
  # Always attempt cleanup, even if the test above failed an assertion, so
  # neither a stray private-socket server nor a temp repo is left behind.
  tmux -L "$TMUX_SOCKET" kill-server 2>/dev/null || true
  if [ -n "$TMP_REPO" ]; then rm -rf "$TMP_REPO"; fi
}

@test ".gitconfig parses" {
  run git config --file "$REPO_ROOT/.gitconfig" --list
  [ "$status" -eq 0 ]
}

@test ".gitaliases parses" {
  run git config --file "$REPO_ROOT/.gitaliases" --list
  [ "$status" -eq 0 ]
}

@test "the cc git alias resolves end to end via the [pretty] custom format" {
  TMP_REPO="$(mktemp -d)"
  git -C "$TMP_REPO" init -q
  git -C "$TMP_REPO" config --local include.path "$REPO_ROOT/.gitaliases"
  git -C "$TMP_REPO" -c user.email=test@test -c user.name=test commit -q --allow-empty -m init

  run git -C "$TMP_REPO" cc init
  [ "$status" -eq 0 ]
}

@test ".vimrc loads and vim quits cleanly" {
  run vim -u "$REPO_ROOT/.vimrc" -es -c ':qa!'
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}

@test ".tmux.conf loads on an isolated socket" {
  run tmux -L "$TMUX_SOCKET" -f "$REPO_ROOT/.tmux.conf" new-session -d
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}
