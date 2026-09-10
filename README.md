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

Verification has four independent parts. All four must pass — a clean `bats tests/` run
locally is not, by itself, a complete check; CI runs all four on every push and pull request as
separate checks (`test`, `shellcheck`, `editorconfig`, `actionlint`).

Install the tooling for all four with:

```sh
brew bundle --file=tests/Brewfile
```

**Behavioural suite** — a [bats](https://github.com/bats-core/bats-core) suite that checks
syntax, config loading, alias sanity, and real shell startup behavior in an isolated sandbox:

```sh
bats tests/
```

**Static analysis** — [ShellCheck](https://www.shellcheck.net) over every bash-family script in
the repository (`.osx`, `tests/install.sh`, `tests/helpers/common.bash`, and the `.bats` files
themselves):

```sh
shellcheck .osx tests/install.sh tests/helpers/common.bash tests/*.bats
```

**Formatting** — [editorconfig-checker](https://github.com/editorconfig-checker/editorconfig-checker)
enforces the conventions declared in `.editorconfig` (final newline, no trailing whitespace,
spaces not tabs) across every tracked file:

```sh
editorconfig-checker
```

**Workflow validation** — [`actionlint`](https://github.com/rhysd/actionlint) over every file in
`.github/workflows/`, checking the workflow structure and running ShellCheck over the shell
inside each `run:` step:

```sh
actionlint
```

These commands approximate what CI runs rather than reproducing it exactly — see
`.github/workflows/ci.yml` for the authoritative discovery/version pinning.

One limitation on workflow validation: a workflow file broken badly enough that GitHub can't
parse it never starts the `actionlint` job at all — that failure surfaces as the automation
declining to run, not as a validation finding, so a green run doesn't prove the workflow parses
in every respect. Running `actionlint` locally before pushing is what catches that case.
