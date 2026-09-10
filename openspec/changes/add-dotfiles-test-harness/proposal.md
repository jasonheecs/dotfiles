## Why

Nothing in this repo checks itself. These files run every time a shell opens, so a typo in
`.zshrc` doesn't break one thing — it breaks *every new terminal window*, and you find out
at the worst possible moment. The recent commit history already shows two behaviour changes
that shipped with no safety net: the `PATH` handling for pnpm was rewritten, and the fnm
startup flags changed.

The fix is a test suite. Cheap checks catch typos instantly; deeper checks actually start a
shell in a sandbox and confirm the environment comes out right; and a CI job runs the whole
thing on a clean macOS machine for every push.

## What Changes

- **Add a test suite** built on [bats](https://github.com/bats-core/bats-core), organised in
  layers that go from instant-and-shallow to slow-and-thorough:
  - syntax — does each file even parse?
  - load — does each tool actually accept its config?
  - shell behaviour — start a real zsh in a sandbox and check `PATH`, aliases, and env vars
  - alias sanity — does every alias point at a command that exists?
- **Add GitHub Actions CI** — runs the suite on `macos-latest` for every push and PR.
- **Add a `Brewfile` for the test tools** (`tests/Brewfile`) so both CI and a fresh machine
  can install `bats-core` and `shellcheck` in one command.
- **Ignore the sandbox cache** — `tests/.cache/` holds the warmed zsh environment the shell
  tests reuse between runs.
- **Document how to run the tests** in the README.
- **Remove one dead alias** — `alias ggl="google"` points at a command that isn't installed,
  so the new alias-sanity check would fail on landing if it stayed.

No dotfile changes behaviour: the only edit to one is deleting that dead alias.

See the [architecture diagram in design.md](design.md#architecture) for how the layers and
the sandbox fit together.

## Scope: one half of a deliberate split

This change covers **verifying the dotfiles that already exist**. It deliberately contains
no reference to an installer, which keeps it standalone — it can land and be useful on its
own.

The companion change, `add-dotfiles-bootstrap`, covers installing the dotfiles onto a
machine: an `install.sh`, the check that every tracked dotfile is actually covered by it,
and the README drift fix that started this whole line of work (`.tmux.conf` was added in
commit `ee60794` and never reached the README). That change depends on this one only for
the bats tooling introduced here.

## Capabilities

### New Capabilities

- `dotfiles-verification`: Checking that the dotfiles are correct — the layered test suite,
  what each layer must catch, how a real shell gets tested without disturbing the user's own
  environment, and what runs automatically.

### Modified Capabilities

None. `openspec/specs/` is currently empty, so the capability above is new and no existing
requirements change.

## Impact

**New files**

- `tests/Brewfile` — test tooling manifest
- `tests/helpers/common.bash` — shared setup and the zsh sandbox helper
- `tests/syntax.bats`, `tests/load.bats`, `tests/invariants.bats`, `tests/shell.bats`
- `.github/workflows/ci.yml` — the CI job

**Modified files**

- `.gitignore` — ignore `tests/.cache/`
- `README.md` — add a Testing section (additive; the setup block is untouched here)
- `.aliases` — remove the dead `ggl` alias

**No changes** to `.zshrc`, `.zimrc`, `.gitconfig`, `.gitaliases`, `.vimrc`, `.tmux.conf`,
or `.osx`. This matters: sandboxing the shell tests turned out to need nothing
from `.zshrc`, because it already derives its paths from `ZDOTDIR`.

**New dependencies**

- `bats-core` (Homebrew) — the test runner
- `shellcheck` (Homebrew) — already installed locally, now also pinned for CI

**Safety note**

`.osx` writes macOS system settings and force-quits Dock, Finder, and Mail. CI must never
execute it — it only gets syntax-checked and linted.
