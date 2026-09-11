# dotfiles

Personal dotfiles for zsh, git, vim, and macOS.

## Contents

| File | Purpose |
| --- | --- |
| `.zshrc` | zsh entry point — bootstraps [Zim](https://github.com/zimfw/zimfw), inits `rbenv`/`fnm` if present, adds pnpm to `PATH`, sources `.aliases` and local overrides |
| `.zimrc` | Zim module manifest (prompt, completions, syntax highlighting, autosuggestions, `agnoster` theme) |
| `.aliases` | A few shell aliases (`Ga`) |
| `.gitconfig` | Global git config — vim as editor, colored output, `osxkeychain` credential helper, includes `.gitaliases` |
| `.gitaliases` | Custom git aliases/functions (`cc`, `cm`, `lrb`, `mpr`, `get`, `pretty`) |
| `.gitignore` | Git's **global** excludes file — `.gitconfig` points `core.excludesfile` at it, so it applies to every repo you work in |
| `.vimrc` | Vim settings |
| `.tmux.conf` | tmux config |
| `.osx` | macOS `defaults write` tweaks for screenshots, Dock, and Mission Control |
| `.editorconfig` | Formatting conventions — governs this repo, and once linked becomes the default for projects that declare none |
| `.claude/CLAUDE.md` | User-level Claude Code preferences |

## Setup

These dotfiles are normally installed for you by the
[mac-dev-setup](https://github.com/jasonheecs/mac-dev-setup) Ansible playbook, which clones this
repo and links them as part of provisioning a machine. `install.sh` is the standalone route, for
a machine you are not provisioning that way. Both produce the same links; only the playbook also
installs software.

Clone the repo, then run the installer — it links every managed dotfile into `$HOME`, backing up
anything already there as `<name>.bak`. Pass `--dry-run` to preview, or `--list` to see what it
manages:

```sh
git clone <repo-url> ~/Projects/dotfiles
~/Projects/dotfiles/install.sh
```

The list mirrors `dotfiles_files` in the playbook's `default.config.yml`, kept in step by hand —
nothing detects drift between the two.

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
- [Zim](https://github.com/zimfw/zimfw) for zsh

## Testing

Verification has four independent parts. All four must pass;
[CI](.github/workflows/ci.yml) runs all four on every push and pull request as separate checks (`test`, `shellcheck`, `editorconfig`, `actionlint`).

Install the tooling for all four locally with:

```sh
brew bundle --file=tests/Brewfile
```

Then run everything with one command:

```sh
make check
```

Run `make help` to list the parts and run one on its own while iterating — the **behavioural
suite** (a [bats](https://github.com/bats-core/bats-core) suite checking syntax, config loading,
alias sanity, and real shell startup behavior in an isolated sandbox), **static analysis**
([ShellCheck](https://www.shellcheck.net) over every bash-family script plus each git alias's
resolved body), **formatting**
([editorconfig-checker](https://github.com/editorconfig-checker/editorconfig-checker) against the
conventions in `.editorconfig`), and **workflow validation**
([`actionlint`](https://github.com/rhysd/actionlint) over `.github/workflows/`).

A clean local run is a strong signal, not a guarantee: tool versions can differ from what CI
pins, and the lint checks run on Linux in CI but macOS locally.
