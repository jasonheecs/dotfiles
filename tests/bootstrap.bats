#!/usr/bin/env bats
# Drives tests/install.sh against a throwaway HOME, covering the four-state
# logic, idempotency, --dry-run, and invocation from an unrelated cwd.

load helpers/common

INSTALL_SH="$REPO_ROOT/tests/install.sh"

install_into() {
  HOME="$1" "$INSTALL_SH" "${@:2}"
}

@test "clean install links all seven managed dotfiles into an empty HOME" {
  run install_into "$BATS_TEST_TMPDIR"
  [ "$status" -eq 0 ]

  for f in .zshrc .zimrc .aliases .gitconfig .gitaliases .vimrc .tmux.conf; do
    [ -L "$BATS_TEST_TMPDIR/$f" ]
    [ "$BATS_TEST_TMPDIR/$f" -ef "$REPO_ROOT/$f" ]
  done
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
