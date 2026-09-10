#!/usr/bin/env bats
# Layer 2: sanity checks that don't fit "does it parse" or "does it load" —
# currently just "does every alias point at something real". Machine-
# dependent, so it's skipped in CI rather than failed.

load helpers/common

@test "every alias in .aliases resolves to a command on PATH" {
  if [ -n "$CI" ]; then
    skip "alias targets are machine-dependent"
  fi

  while IFS= read -r line; do
    value=$(printf '%s\n' "$line" | sed -E 's/^alias [^=]+="(.*)"$/\1/')
    cmd=$(printf '%s\n' "$value" | awk '{print $1}')
    run command -v "$cmd"
    [ "$status" -eq 0 ]
  done < "$REPO_ROOT/.aliases"
}
