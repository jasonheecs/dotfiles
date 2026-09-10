# dotfiles

Personal dotfiles for zsh, git, vim, and macOS.

## Contents

| File | Purpose |
| --- | --- |
| `.zshrc` | zsh entry point — bootstraps [Zim](https://github.com/zimfw/zimfw), inits `rbenv`/`fnm` if present, adds pnpm to `PATH`, sources `.aliases` and local overrides |
| `.zimrc` | Zim module manifest (prompt, completions, syntax highlighting, autosuggestions, `agnoster` theme) |
| `.aliases` | A few shell aliases (`Ga`) |
| `.gitconfig` | Global git config — vim as editor, colored output, `osxkeychain` credential helper, includes `.gitaliases` |
| `.gitaliases` | Custom git aliases/functions (`cc`, `cm`, `lrb`, `mpr`, `retag`, `get`, `pretty`) |
| `.vimrc` | Vim settings |
| `.tmux.conf` | tmux config |
| `.osx` | macOS `defaults write` tweaks for screenshots, Dock, and Mission Control |
| `.claude/CLAUDE.md` | Project-level Claude Code conventions for this repo |

## Setup

Clone the repo, then run the installer — it links all seven managed dotfiles into `$HOME`,
backing up anything already there as `<name>.bak`. Pass `--dry-run` to preview:

```sh
git clone <repo-url> ~/Projects/dotfiles
~/Projects/dotfiles/tests/install.sh
```

Or symlink the files you want by hand:

```sh
cd ~/Projects/dotfiles
ln -sf "$PWD/.zshrc"     ~/.zshrc
ln -sf "$PWD/.zimrc"     ~/.zimrc
ln -sf "$PWD/.aliases"   ~/.aliases
ln -sf "$PWD/.gitconfig" ~/.gitconfig
ln -sf "$PWD/.gitaliases" ~/.gitaliases
ln -sf "$PWD/.vimrc"     ~/.vimrc
ln -sf "$PWD/.tmux.conf" ~/.tmux.conf
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

## Testing

The dotfiles are covered by a [bats](https://github.com/bats-core/bats-core) suite that
checks syntax, config loading, alias sanity, and real shell startup behavior in an isolated
sandbox. Install the test tooling and run it with:

```sh
brew bundle --file=tests/Brewfile
bats tests/
```

CI runs the same suite on every push and pull request.
