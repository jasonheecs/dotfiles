#!/usr/bin/env bats
# Drives install.sh against a throwaway HOME, covering the four-state
# logic, idempotency, --dry-run, and invocation from an unrelated cwd.

load helpers/common

INSTALL_SH="$REPO_ROOT/install.sh"

install_into() {
  HOME="$1" "$INSTALL_SH" "${@:2}"
}

@test "clean install links every managed dotfile into an empty HOME" {
  run install_into "$BATS_TEST_TMPDIR"
  [ "$status" -eq 0 ]

  # Asked of the installer rather than repeated here, so adding a dotfile
  # needs no edit to this file. Sandboxed like every other invocation, so a
  # --list that stopped exiting early couldn't reach the real $HOME.
  managed=$(install_into "$BATS_TEST_TMPDIR" --list)
  # Guards against the loop passing vacuously on an empty list.
  [ -n "$managed" ]

  while IFS= read -r f; do
    [ -L "$BATS_TEST_TMPDIR/$f" ]
    [ "$BATS_TEST_TMPDIR/$f" -ef "$REPO_ROOT/$f" ]
  done <<< "$managed"
}

@test "a nested entry is linked inside a real directory, not a linked one" {
  run install_into "$BATS_TEST_TMPDIR"
  [ "$status" -eq 0 ]

  [ "$BATS_TEST_TMPDIR/.claude/CLAUDE.md" -ef "$REPO_ROOT/.claude/CLAUDE.md" ]
  # ~/.claude holds live local state, so only the one file is managed —
  # linking the directory itself would replace it with the repo's copy.
  [ -d "$BATS_TEST_TMPDIR/.claude" ]
  [ ! -L "$BATS_TEST_TMPDIR/.claude" ]
}

@test "a second run leaves a nested entry unchanged with no backup" {
  install_into "$BATS_TEST_TMPDIR"

  run install_into "$BATS_TEST_TMPDIR"
  [ "$status" -eq 0 ]
  [[ "$output" == *"unchanged: $BATS_TEST_TMPDIR/.claude/CLAUDE.md"* ]]
  [ ! -e "$BATS_TEST_TMPDIR/.claude/CLAUDE.md.bak" ]
}

@test "--dry-run does not create a missing parent directory" {
  run install_into "$BATS_TEST_TMPDIR" --dry-run
  [ "$status" -eq 0 ]
  [ ! -e "$BATS_TEST_TMPDIR/.claude" ]
  [[ "$output" == *"$BATS_TEST_TMPDIR/.claude/CLAUDE.md"* ]]
}

@test "running twice is idempotent: no backups, no changed links, exit 0" {
  install_into "$BATS_TEST_TMPDIR"

  run install_into "$BATS_TEST_TMPDIR"
  [ "$status" -eq 0 ]
  [[ "$output" != *"backing up"* ]]
  [[ "$output" != *"replacing"* ]]

  run find "$BATS_TEST_TMPDIR" -maxdepth 1 -name '*.bak'
  [ -z "$output" ]
}

@test "a pre-existing regular file is preserved as a .bak with its contents intact" {
  echo "my real zshrc" > "$BATS_TEST_TMPDIR/.zshrc"

  run install_into "$BATS_TEST_TMPDIR"
  [ "$status" -eq 0 ]

  [ -f "$BATS_TEST_TMPDIR/.zshrc.bak" ]
  [ "$(cat "$BATS_TEST_TMPDIR/.zshrc.bak")" = "my real zshrc" ]
  [ "$BATS_TEST_TMPDIR/.zshrc" -ef "$REPO_ROOT/.zshrc" ]
}

@test "a correct existing symlink is left untouched, no backup created" {
  ln -s "$REPO_ROOT/.vimrc" "$BATS_TEST_TMPDIR/.vimrc"

  run install_into "$BATS_TEST_TMPDIR"
  [ "$status" -eq 0 ]
  [[ "$output" == *"unchanged: $BATS_TEST_TMPDIR/.vimrc"* ]]
  [ ! -e "$BATS_TEST_TMPDIR/.vimrc.bak" ]
}

@test "a symlink pointing elsewhere is replaced with the correct link" {
  ln -s /etc/hosts "$BATS_TEST_TMPDIR/.vimrc"

  run install_into "$BATS_TEST_TMPDIR"
  [ "$status" -eq 0 ]
  [ "$BATS_TEST_TMPDIR/.vimrc" -ef "$REPO_ROOT/.vimrc" ]
  [ ! -e "$BATS_TEST_TMPDIR/.vimrc.bak" ]
}

@test "a symlink pointing at a directory is replaced, not followed" {
  mkdir "$BATS_TEST_TMPDIR/elsewhere"
  ln -s "$BATS_TEST_TMPDIR/elsewhere" "$BATS_TEST_TMPDIR/.vimrc"

  run install_into "$BATS_TEST_TMPDIR"
  [ "$status" -eq 0 ]
  [ "$BATS_TEST_TMPDIR/.vimrc" -ef "$REPO_ROOT/.vimrc" ]
  [ -z "$(ls -A "$BATS_TEST_TMPDIR/elsewhere")" ]
}

@test "--list prints the manifest and makes no changes" {
  run install_into "$BATS_TEST_TMPDIR" --list
  [ "$status" -eq 0 ]
  [ -n "$output" ]

  run find "$BATS_TEST_TMPDIR" -mindepth 1
  [ -z "$output" ]
}

@test "--dry-run makes no changes and exits 0" {
  run install_into "$BATS_TEST_TMPDIR" --dry-run
  [ "$status" -eq 0 ]

  run find "$BATS_TEST_TMPDIR" -mindepth 1
  [ -z "$output" ]
}

@test "invoking by absolute path from an unrelated cwd still resolves into the repo" {
  run bash -c "cd / && HOME='$BATS_TEST_TMPDIR' '$INSTALL_SH'"
  [ "$status" -eq 0 ]
  [ "$BATS_TEST_TMPDIR/.zshrc" -ef "$REPO_ROOT/.zshrc" ]
}
