#!/usr/bin/env bats
# Layer 0: does each file even parse? Checkers are matched to the file's
# actual shell language — shellcheck doesn't understand zsh, so it never
# runs against a zsh file.

load helpers/common

@test ".zshrc has valid zsh syntax" {
  run zsh -n "$REPO_ROOT/.zshrc"
  [ "$status" -eq 0 ]
}

@test ".aliases has valid zsh syntax" {
  run zsh -n "$REPO_ROOT/.aliases"
  [ "$status" -eq 0 ]
}

@test ".zimrc has valid zsh syntax" {
  run zsh -n "$REPO_ROOT/.zimrc"
  [ "$status" -eq 0 ]
}

@test ".osx has valid bash syntax" {
  run bash -n "$REPO_ROOT/.osx"
  [ "$status" -eq 0 ]
}
