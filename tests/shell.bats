#!/usr/bin/env bats
# Layer 3: start a real interactive zsh and assert on the resulting
# environment. The only layer that needs isolation — see helpers/common.bash
# for the HOME/ZDOTDIR sandbox this relies on.

load helpers/common

setup_file() {
  setup_zdot_sandbox
  # Warm the zim cache once, up front, so the stripped-PATH test below never
  # needs to reach `brew` for a fresh zimfw init.
  sandboxed_zsh 'true' >/dev/null 2>&1
}

setup() {
  setup_zdot_sandbox
}

@test "interactive startup exits 0 with empty output" {
  run sandboxed_zsh 'true'
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}

@test "pnpm bin dir appears in PATH exactly once after loading .zshrc twice" {
  # Must reach the sandboxed shell unexpanded so that shell resolves $PATH,
  # not this one.
  # shellcheck disable=SC2016
  run sandboxed_zsh 'source "$ZDOTDIR/.zshrc"; echo $PATH'
  [ "$status" -eq 0 ]
  count=$(grep -o "${ZDOT_SANDBOX}/Library/pnpm/bin" <<< "$output" | wc -l | tr -d ' ')
  [ "$count" -eq 1 ]
}

@test "HOMEBREW_AUTO_UPDATE_SECS is set" {
  # Must reach the sandboxed shell unexpanded so that shell resolves
  # $HOMEBREW_AUTO_UPDATE_SECS, not this one.
  # shellcheck disable=SC2016
  run sandboxed_zsh 'echo $HOMEBREW_AUTO_UPDATE_SECS'
  [ "$status" -eq 0 ]
  [ "$output" = "604800" ]
}

# Derived from $HOME, so this also pins the sandbox: a leak would point it at
# the real home directory.
@test "PNPM_HOME is set" {
  # Must reach the sandboxed shell unexpanded so that shell resolves
  # $PNPM_HOME, not this one.
  # shellcheck disable=SC2016
  run sandboxed_zsh 'echo $PNPM_HOME'
  [ "$status" -eq 0 ]
  [ "$output" = "${ZDOT_SANDBOX}/Library/pnpm" ]
}

@test "aliases from .aliases are defined" {
  run sandboxed_zsh 'alias Ga'
  [ "$status" -eq 0 ]
}

@test "startup succeeds when rbenv and fnm are absent from PATH" {
  run env PATH="/usr/bin:/bin" HOME="$ZDOT_SANDBOX" ZDOTDIR="$ZDOT_SANDBOX" zsh -i -c true
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}
