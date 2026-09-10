#!/usr/bin/env bash
# Symlinks this repo's dotfiles into $HOME. Safe to run repeatedly; pass
# --dry-run to preview without touching the filesystem.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

LINK_FILES=(
  .zshrc
  .zimrc
  .aliases
  .gitconfig
  .gitaliases
  .vimrc
  .tmux.conf
)

# Parallel arrays, not an associative array: macOS ships bash 3.2, which
# `declare -A` doesn't support.
EXCLUDED_FILES=(
  .osx
  .gitignore
  .editorconfig
  .editorconfig-checker.json
)
EXCLUDED_REASONS=(
  "executed on demand, never linked"
  "applies to the repository itself"
  "applies to the repository itself"
  "applies to the repository itself"
)

DRY_RUN=0
for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=1 ;;
    *)
      echo "usage: $0 [--dry-run]" >&2
      exit 1
      ;;
  esac
done

# Runs $* for real, or just prints it under --dry-run. Both modes share this
# one path so a dry run can never compute a different plan than the real run.
run_or_echo() {
  if [ "$DRY_RUN" -eq 1 ]; then
    echo "would run: $*"
  else
    "$@"
  fi
}

install_link() {
  local name="$1"
  local target="$HOME/$name"
  local src="$REPO_ROOT/$name"

  if [ -L "$target" ]; then
    if [ "$target" -ef "$src" ]; then
      echo "unchanged: $target"
      return
    fi
    echo "replacing: $target"
    # -n, else a symlink to a directory gets followed and the new link lands
    # inside it instead of replacing it.
    run_or_echo ln -sfn "$src" "$target"
    return
  fi

  if [ -e "$target" ]; then
    local backup="$target.bak"
    if [ -e "$backup" ]; then
      echo "error: $backup already exists, refusing to overwrite it" >&2
      exit 1
    fi
    echo "backing up: $target -> $backup"
    run_or_echo mv "$target" "$backup"
  fi

  echo "linking: $target"
  run_or_echo ln -s "$src" "$target"
}

for i in "${!EXCLUDED_FILES[@]}"; do
  echo "excluded: ${EXCLUDED_FILES[$i]} (${EXCLUDED_REASONS[$i]})"
done

for name in "${LINK_FILES[@]}"; do
  install_link "$name"
done
