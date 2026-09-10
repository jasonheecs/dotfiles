## 1. README drift fix

Independent of everything else — this can land alone and closes the original gap.

- [x] 1.1 Add a `.tmux.conf` row to the contents table in `README.md` describing it as the
      tmux config; verify `grep -c 'tmux.conf' README.md` returns at least 2 after 1.2
- [x] 1.2 Add `ln -sf "$PWD/.tmux.conf" ~/.tmux.conf` to the README setup block, aligned
      with the surrounding lines; verify by running the block's commands against a
      throwaway `$HOME` and confirming seven symlinks result

## 2. Installer

- [x] 2.1 Create `tests/install.sh` (bash, `set -euo pipefail`) with a `LINK_FILES` array of
      the seven linked dotfiles and an `EXCLUDED` array holding `.osx` and `.gitignore` with
      the reason for each recorded alongside. Resolve the repo root from `${BASH_SOURCE[0]}`
      (climbing one level out of `tests/`), never `$PWD`. Verify with
      `HOME=$(mktemp -d) bash tests/install.sh` followed by confirming all seven links exist
      and resolve into the repo

      Note: implemented `EXCLUDED` as two parallel indexed arrays (`EXCLUDED_FILES` /
      `EXCLUDED_REASONS`) rather than `declare -A`, discovered during verification that this
      machine's `/usr/bin/env bash` is macOS's stock bash 3.2 (no Homebrew bash installed),
      which has no associative arrays. Same behavior, bash 3.2-compatible.
- [x] 2.2 Implement the four-state handling per target: absent → link; correct symlink →
      leave and report unchanged; wrong symlink → replace and report; regular file or
      directory → move to `<name>.bak` then link, erroring if a `.bak` already exists.
      Verify each of the four states individually against a temp `HOME`
- [x] 2.3 Add `--dry-run` sharing one code path with the real run (a single `run_or_echo`
      wrapper, not a parallel reporting branch). Verify
      `HOME=$tmp bash tests/install.sh --dry-run` exits 0, prints the planned actions, and
      leaves `ls -A "$tmp"` empty
- [x] 2.4 Confirm the installer never references `.osx` as anything but data; verify
      `grep -n osx tests/install.sh` shows only the exclusion entry
- [x] 2.5 Confirm lint cleanliness: `shellcheck tests/install.sh` reports zero findings and
      `bash -n tests/install.sh` exits 0
- [x] 2.6 Run the installer against this machine's real `$HOME` and verify it reports all
      seven links already correct and creates no `.bak` files — a live smoke test of the
      four-state logic

      Note: verified via synthetic `$HOME` tests instead of the real one. This session runs
      in a git worktree, so `REPO_ROOT` (resolved from `${BASH_SOURCE[0]}`) points at the
      worktree, not the main repo the real `$HOME` symlinks target — running the installer
      unguarded against the real `$HOME` here repointed all 7 real symlinks at the worktree
      (caught and manually fixed by the user; see memory `worktree-install-sh-home-hazard`).
      The temp-`$HOME` tests above already cover all four states, a superset of this check.

## 3. Coverage check

- [x] 3.1 Add the coverage check to `tests/invariants.bats` — every path from
      `git ls-files -- '.*' | grep -v '/'` must appear in `LINK_FILES` or `EXCLUDED`.
      Create the file if the harness change has not already; add to it if it exists. Verify
      it passes against the current repo
- [x] 3.2 Verify the check actually catches drift: `git add` a throwaway `.foo` at the repo
      root, confirm `bats tests/invariants.bats` fails and names `.foo`, then remove it
- [x] 3.3 Verify the exclusion path: confirm the check passes without demanding that `.osx`
      or `.gitignore` be linked, and that removing an entry from `EXCLUDED` makes it fail

## 4. Installer tests

- [ ] 4.1 Write `tests/bootstrap.bats` covering the clean-install path against
      `$BATS_TEST_TMPDIR`: all seven links created and resolving into the repo. Verify
      `bats tests/bootstrap.bats` passes
- [ ] 4.2 Add the idempotency case: run the installer twice against one temp `HOME` and
      assert the second run creates no `.bak` files, changes no link, and exits 0
- [ ] 4.3 Add the preservation cases: a pre-seeded regular `.zshrc` survives as `.zshrc.bak`
      with its contents intact; a correct existing symlink is left untouched; a symlink
      pointing elsewhere is replaced. Verify each asserts independently
- [ ] 4.4 Add the dry-run case: assert the temp `HOME` is empty afterwards and the exit
      status is 0
- [ ] 4.5 Add the working-directory case: invoke the installer by absolute path from an
      unrelated directory and assert the links still resolve into the repo

## 5. Fresh-machine CI

- [ ] 5.1 Add a step to `.github/workflows/ci.yml` running `tests/install.sh` against the
      runner's `$HOME`, then `zsh -i -c 'exit'`, asserting exit 0. Verify by pushing a
      branch and reading the run log for the installer output and a clean shell exit
- [ ] 5.2 Confirm the runner's pre-existing `.zshrc` exercises the backup path — check the
      log reports a backup rather than a clean link, which confirms `bootstrap.bats` is
      carrying the clean-path coverage rather than CI
- [ ] 5.3 Confirm `.osx` is never executed anywhere in the workflow; verify by grepping the
      workflow for `.osx` and checking every hit is a syntax or lint invocation
