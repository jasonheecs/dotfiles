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

array_entries() {
  sed -n "/^$1=(/,/^)/p" "$REPO_ROOT/tests/install.sh" | grep -oE '\.[A-Za-z0-9_.-]+'
}

@test "every excluded file records why it is not installed" {
  files=$(array_entries EXCLUDED_FILES | grep -c .)
  reasons=$(sed -n '/^EXCLUDED_REASONS=(/,/^)/p' "$REPO_ROOT/tests/install.sh" | grep -c '"')
  [ "$files" -eq "$reasons" ]
}

@test "every tracked root dotfile is installed or excluded by tests/install.sh" {
  linked=$(array_entries LINK_FILES)
  excluded=$(array_entries EXCLUDED_FILES)

  missing=()
  while IFS= read -r f; do
    if ! grep -qxF "$f" <<< "$linked" && ! grep -qxF "$f" <<< "$excluded"; then
      missing+=("$f")
    fi
  done < <(git -C "$REPO_ROOT" ls-files -- '.*' | grep -v '/')

  if [ "${#missing[@]}" -ne 0 ]; then
    echo "unaccounted-for dotfile(s): ${missing[*]}" >&2
    return 1
  fi
}
