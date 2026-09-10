#!/usr/bin/env bash
# Lints each git alias's *resolved* shell body -- what git actually runs --
# instead of the .gitaliases source text, which can hide broken quoting
# (see proposal.md's escaping trap). Reports every broken alias, not just
# the first.
set -euo pipefail

aliases_file=${1:-.gitaliases}

# "$@" goes once at the end of the whole (possibly multi-line) value, matching
# how git invokes the body -- appending per line would land it inside a
# multi-line commit message (mpr) and produce bogus findings.
as_script() {
  printf '#!/bin/sh\n%s "$@"\n' "$1"
}

# No-ops on plain (non-shell) alias values.
lint_alias() {
  local name=$1 value=$2
  [[ $value == '!'* ]] || return 0

  echo "::group::shellcheck $name"
  as_script "${value#!}" | shellcheck -s sh -
  local result=$?
  echo "::endgroup::"
  [ "$result" -eq 0 ] || echo "::error::git alias '$name' failed shellcheck"
  return "$result"
}

status=0
# -z NUL-delimits records; within a record, key and value are joined by one
# real newline, so this split isolates the value without disturbing any
# *further* embedded newlines it may itself contain (again, mpr).
while IFS= read -r -d '' record; do
  name=${record%%$'\n'*}
  value=${record#*$'\n'}
  lint_alias "${name#alias.}" "$value" || status=1
done < <(git config --file "$aliases_file" -z --get-regexp '^alias\.')

exit "$status"
