## 1. Test tooling

- [x] 1.1 Create `tests/Brewfile` declaring `bats-core` and `shellcheck`; verify
      `brew bundle check --file=tests/Brewfile` reports satisfied after
      `brew bundle --file=tests/Brewfile`
- [x] 1.2 Add `tests/.cache/` to `.gitignore`; verify with
      `git check-ignore -q tests/.cache/anything && echo ignored`
- [ ] 1.3 Create `tests/helpers/common.bash` exporting a `REPO_ROOT` resolved from
      `${BASH_SOURCE[0]}` (not `$PWD`) plus shared setup helpers; verify by sourcing it from
      a throwaway working directory and echoing `$REPO_ROOT`

## 2. Fast layers (0-2)

No isolation needed; these should run in well under a second.

- [ ] 2.1 Write `tests/syntax.bats`: `zsh -n` over `.zshrc`, `.aliases`, `.zimrc`; `bash -n`
      and `shellcheck` over `.osx`. Never shellcheck a zsh file. Verify
      `bats tests/syntax.bats` passes against the current repo
- [ ] 2.2 Write `tests/load.bats` covering: both git config files parse via
      `git config --file ... --list`; a git alias depending on `--pretty=custom` runs
      successfully in a throwaway repo; `vim -u .vimrc -es -c ':qa!'` exits 0; `.tmux.conf`
      loads on a private socket (`tmux -L "bats-$$"`) with a `teardown()` that kills that
      server. Verify `bats tests/load.bats` passes and `tmux ls` on the default socket is
      unaffected
- [ ] 2.3 Remove `alias ggl="google"` from `.aliases` — `google` is not on `PATH`, so the
      check added in 2.4 would otherwise fail on landing. Verify `zsh -n .aliases` exits 0
      and `grep -c ggl .aliases` returns 0
- [ ] 2.4 Write `tests/invariants.bats` with the alias-target check — each alias in
      `.aliases` resolves to a command on `PATH` — guarded by `skip` when `$CI` is set.
      Verify it passes on this machine after 2.3, reports skipped under
      `CI=1 bats tests/invariants.bats`, and fails if a bogus alias is temporarily added

## 3. Sandboxed shell layer (3)

- [ ] 3.1 Extend `tests/helpers/common.bash` with the zsh sandbox: create
      `tests/.cache/zdot`, symlink `.zshrc`/`.zimrc`/`.aliases` into it, and provide a
      helper that runs zsh with both `HOME` and `ZDOTDIR` pointed there. Verify the first
      call warms the cache and a second call is materially faster
- [ ] 3.2 Write `tests/shell.bats` asserting: interactive startup exits 0 with empty stderr;
      `$PNPM_HOME/bin` appears in `PATH` exactly once after loading `.zshrc` twice;
      `HOMEBREW_AUTO_UPDATE_SECS` is `604800`; the `.aliases` aliases are defined; and
      startup succeeds with a stripped `PATH` where `rbenv` and `fnm` are absent. Verify
      `bats tests/shell.bats` passes and that no file under the real `$HOME` was touched

## 4. Continuous integration

- [ ] 4.1 Add `.github/workflows/ci.yml` running on push and pull_request against
      `macos-latest`: checkout, `actions/cache` on `tests/.cache` keyed by
      `hashFiles('.zimrc')`, `brew bundle --file=tests/Brewfile`, then `bats tests/`.
      Verify by pushing a branch and confirming the job goes green
- [ ] 4.2 Confirm `.osx` is never executed anywhere in the workflow — it appears only as an
      argument to `bash -n` and `shellcheck`. Verify by grepping the workflow and
      `tests/*.bats` for `.osx` and checking every hit is a syntax or lint invocation
- [ ] 4.3 Confirm the cache actually hits: re-run the workflow with `.zimrc` unchanged and
      verify the log reports a cache hit and the shell layer is faster than the cold run
- [ ] 4.4 Add a Testing section to `README.md` documenting
      `brew bundle --file=tests/Brewfile && bats tests/`; verify the commands in it run
      successfully as written from a clean checkout

## 5. Prove the harness catches regressions

Broader validation spanning every layer — run after groups 1-4 land. Revert each injection
after confirming it goes red.

- [ ] 5.1 Inject an unbalanced construct into `.zshrc` and verify `tests/syntax.bats` fails
      and names the file
- [ ] 5.2 Remove the `case`-based `PATH` guard from `.zshrc` and verify the duplicate-entry
      assertion in `tests/shell.bats` fails
- [ ] 5.3 Delete the `[pretty]` block from `.gitaliases` and verify the git alias test in
      `tests/load.bats` fails
- [ ] 5.4 Introduce a lint violation into `.osx` and verify the shellcheck assertion in
      `tests/syntax.bats` fails
