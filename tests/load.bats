#!/usr/bin/env bats
# Layer 1: does each tool actually accept its config? No isolation needed —
# these just read files, they don't touch any running instance of the tool.

load helpers/common

setup() {
  TMUX_SOCKET="bats-$$"
}

teardown() {
  # Always attempt cleanup, even if the test above failed an assertion, so a
  # stray private-socket server is never left running.
  tmux -L "$TMUX_SOCKET" kill-server 2>/dev/null || true
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
  tmp_repo="$(mktemp -d)"
  git -C "$tmp_repo" init -q
  git -C "$tmp_repo" config --local include.path "$REPO_ROOT/.gitaliases"
  git -C "$tmp_repo" -c user.email=test@test -c user.name=test commit -q --allow-empty -m init

  run git -C "$tmp_repo" cc init
  [ "$status" -eq 0 ]

  rm -rf "$tmp_repo"
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
