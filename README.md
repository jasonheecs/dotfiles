# dotfiles

Personal dotfiles for zsh, git, vim, and macOS.

## Contents

| File | Purpose |
| --- | --- |
| `.zshrc` | zsh entry point — bootstraps [Zim](https://github.com/zimfw/zimfw), inits `rbenv`/`fnm` if present, adds pnpm to `PATH`, sources `.aliases` and local overrides |
| `.zimrc` | Zim module manifest (prompt, completions, syntax highlighting, autosuggestions, `agnoster` theme) |
| `.aliases` | A few shell aliases (`ggl`, `v`, `Ga`) |
| `.gitconfig` | Global git config — vim as editor, colored output, `osxkeychain` credential helper, includes `.gitaliases` |
| `.gitaliases` | Custom git aliases/functions (`cc`, `cm`, `lrb`, `mpr`, `retag`, `get`, `pretty`) |
| `.vimrc` | Vim settings |
| `.osx` | macOS `defaults write` tweaks for screenshots, Dock, and Mission Control |
| `.claude/CLAUDE.md` | Project-level Claude Code conventions for this repo |

## Setup

Clone the repo, then symlink the files you want into `$HOME`:

```sh
git clone <repo-url> ~/Projects/dotfiles
cd ~/Projects/dotfiles
ln -sf "$PWD/.zshrc"     ~/.zshrc
ln -sf "$PWD/.zimrc"     ~/.zimrc
ln -sf "$PWD/.aliases"   ~/.aliases
ln -sf "$PWD/.gitconfig" ~/.gitconfig
ln -sf "$PWD/.gitaliases" ~/.gitaliases
ln -sf "$PWD/.vimrc"     ~/.vimrc
```

Apply the macOS defaults (optional, restarts affected apps unless `--no-restart` is passed):

```sh
./.osx
```

### Local overrides (not tracked)

These files are sourced/included if present but are gitignored, so create them yourself for machine-specific or private settings:

- `~/.zshrc.extra` — extra zsh config sourced at the end of `.zshrc`
- `~/.gitcredentials` — included by `.gitconfig`, e.g. for `user.email`

## Requirements

- [Homebrew](https://brew.sh)
- [Zim](https://github.com/zimfw/zimfw) for zsh (installed via `zimfw` from Homebrew)
