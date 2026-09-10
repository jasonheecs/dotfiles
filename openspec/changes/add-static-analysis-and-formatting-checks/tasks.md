## 1. Settle the discovery question

- [x] 1.1 Determine whether `ludeeus/action-shellcheck` classifies `#!/usr/bin/env bats` files
      as shell scripts, by reading the action's documented inputs and running it once against
      this repository on a throwaway branch. Verify by confirming the run's output names all
      five `tests/*.bats` files. Record the finding in `design.md` under Decisions.
- [x] 1.2 If 1.1 shows `.bats` files are skipped, bring them into scope using the action's
      additional-file-pattern input, and verify the same way — the run names all five files.
      If no input achieves it, switch the design to the git-based enumeration fallback
      documented under Decisions and note why in `design.md`.
- [x] 1.3 Confirm the same run does NOT name `.zshrc`, `.aliases`, or `.zimrc`. Verify by
      checking those three are absent from the run's file list; if any appears, add an ignore
      rule and re-run until absent.

## 2. Make the tree clean under repo-wide static analysis

- [x] 2.1 Add per-line `# shellcheck disable=SC2016` directives above `tests/shell.bats` lines
      26, 33, and 41, each with a comment stating that the single quotes are deliberate
      because the string must reach the sandboxed shell unexpanded. Verify with
      `shellcheck tests/shell.bats` exiting 0, and `bats tests/shell.bats` still passing.
- [x] 2.2 Remove the `.osx passes shellcheck` test from `tests/syntax.bats`, leaving its parse
      checks intact. Verify with `bats tests/syntax.bats` passing with one fewer test, and no
      remaining shellcheck invocation in the file.
- [x] 2.3 Confirm the whole repository is clean by running the analyser over every bash-family
      file at once and verifying it exits 0 with no output.

## 3. Declare the formatting conventions

- [x] 3.1 Add `.editorconfig` with repository-wide settings (space indentation, final newline,
      no trailing whitespace, UTF-8) and per-file-type indent widths: two for shell and bats
      files, four for `.gitconfig`, `.gitaliases`, and `.vimrc`. Verify by opening one file of
      each type in an editor that reads it and confirming the reported indent width matches.
- [x] 3.2 Add a final newline to `.gitconfig`, `.gitaliases`, `.tmux.conf`, and `.osx`. Verify
      that each file's last byte is a newline, and that `bats tests/` still passes — the suite
      already covers git config parsing, tmux config loading, and `.osx` syntax.
- [x] 3.3 Normalise the mixed indentation in `.zshrc` so the `source_if_exists` body matches the
      two-space convention used by the rest of the file. Verify with `zsh -n .zshrc` and
      `bats tests/shell.bats` both passing.
- [x] 3.4 Add `expandtab`, an explicit indent width, and a `FileType` autocommand narrowing
      shell files to two spaces in `.vimrc`. Verify by opening a `.sh` file and a `.gitconfig`
      in vim, inserting an indent in each, and confirming spaces are written at the expected
      width for that file type.

## 4. Add the CI jobs

- [ ] 4.1 Add a job named `shellcheck` to `.github/workflows/ci.yml`, running on
      `ubuntu-latest`, triggered by the existing `push` and `pull_request` events, using the
      discovery mechanism settled in group 1 and a pinned analyser version. Verify by pushing
      and confirming a distinctly-named check appears on the run.
- [ ] 4.2 Add a job named `editorconfig` to the same workflow, running on `ubuntu-latest`,
      enforcing `.editorconfig` across tracked files with a pinned tool version. Verify by
      pushing and confirming a distinctly-named check appears and passes.
- [ ] 4.3 Resolve the first full formatting run's findings on files this change did not
      anticipate — `openspec/` artifacts, `README.md`, `.github/` YAML. Fix each or add a
      deliberate, reasoned entry to the tool's ignore configuration. Verify the job passes with
      an ignore list short enough to read at a glance.
- [ ] 4.4 Verify the `shellcheck` job fails on a violation: temporarily introduce an unquoted
      expansion into a bash script, confirm the check goes red and names the file and rule,
      then revert.
- [ ] 4.5 Verify the `shellcheck` job actually covers `.bats` files: temporarily introduce a
      violation into one of `tests/*.bats`, confirm the check goes red and names that file,
      then revert. This is the specific gap the change exists to close, so it is verified
      directly rather than inferred from 4.4.
- [ ] 4.6 Verify the `editorconfig` job fails on a violation: temporarily strip the final
      newline from a tracked file, confirm the check goes red and names it, then revert.
- [ ] 4.7 Verify the three jobs are independent: confirm from the run's timing that `test`,
      `shellcheck`, and `editorconfig` start in parallel and that none is gated on another.

## 5. Document the split

- [ ] 5.1 Update the Testing section of `README.md` to state that verification has three parts,
      that `bats tests/` alone is no longer a complete check, and to give the command for
      running each part locally. Verify by following the README's own instructions from a clean
      shell and getting a clean run of each.
- [ ] 5.2 Add `editorconfig-checker` to `tests/Brewfile` alongside the existing `shellcheck`
      entry, so both linters are installable locally in one step. Verify with
      `brew bundle --file=tests/Brewfile` followed by `command -v shellcheck` and
      `command -v editorconfig-checker`.
