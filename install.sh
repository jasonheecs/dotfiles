#!/usr/bin/env bash
# Symlinks this repo's dotfiles into $HOME. Safe to run repeatedly; pass
# --dry-run to preview without touching the filesystem.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# .github/workflows/ci.yml is the one tracked dotfile deliberately left out:
# it configures this repository's CI and means nothing in $HOME. .osx is
# linked but never run -- linking a script and running it are different acts.
LINK_FILES=(
  .aliases
  .claude/CLAUDE.md
  .editorconfig
  .gitaliases
  .gitconfig
  .gitignore
  .osx
  .tmux.conf
  .vimrc
  .zimrc
  .zshrc
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

  # Entries naming a subdirectory need it to exist first. Guarded on -d so a
  # dry run stays quiet for the entries whose parent is plain $HOME.
  local parent
  parent="$(dirname "$target")"
  [ -d "$parent" ] || run_or_echo mkdir -p "$parent"

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

for name in "${LINK_FILES[@]}"; do
  install_link "$name"
done
