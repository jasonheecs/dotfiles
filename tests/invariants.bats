#!/usr/bin/env bats
# Layer 2: sanity checks that don't fit "does it parse" or "does it load" —
# currently just "does every alias point at something real". Machine-
# dependent, so it's skipped in CI rather than failed.

load helpers/common

# Reads zsh's own alias table instead of regexing the file, so quoting style,
# comments, and blank lines are zsh's problem. `unalias -a` drops the two
# aliases zsh seeds by default (run-help, which-command).
repo_aliases() {
  zsh -f -c 'unalias -a; source "$1"; for k v in ${(kv)aliases}; do print -r -- "$k=$v"; done' \
    zsh "$REPO_ROOT/.aliases"
}

@test "every alias in .aliases resolves to a command on PATH" {
  if [ -n "$CI" ]; then
    skip "alias targets are machine-dependent"
  fi

  run repo_aliases
  [ "$status" -eq 0 ]
  # Guards against the check passing vacuously on an unreadable alias table.
  [ -n "$output" ]

  while IFS= read -r entry; do
    target=${entry#*=}
    cmd=${target%% *}
    if ! command -v "$cmd" >/dev/null 2>&1; then
      echo "alias ${entry%%=*} -> '$cmd' is not on PATH"
      return 1
    fi
  done <<< "$output"
}
