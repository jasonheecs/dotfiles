## 1. Remove the unused alias

- [x] 1.1 Delete the `retag` alias and its comment block from `.gitaliases`. Verify with
      `git config -f .gitaliases --get alias.retag` returning nothing and a non-zero status, and
      `git config -f .gitaliases --list` still parsing.
- [ ] 1.2 Remove `retag` from the alias list in the `.gitaliases` row of `README.md`. Verify no
      reference to it survives anywhere in the repository.

## 2. Fix the escaping bugs

- [ ] 2.1 Escape the inner quotes in the `lrb` alias so its expansions stay quoted. Verify with
      `git config -f .gitaliases --get alias.lrb` showing `remote="${1:-origin}"` and
      `--heads "$remote"` with quotes intact.
- [ ] 2.2 Escape the inner quotes in the `get` alias. Verify with
      `git config -f .gitaliases --get alias.get` showing both `"$1"` occurrences quoted.
- [ ] 2.3 Confirm the two fixed aliases are clean under analysis: extract each resolved body,
      prepend `#!/bin/sh`, append `"$@"`, and verify `shellcheck -s sh` exits 0 for both.

## 3. Rewrite `mpr`

- [ ] 3.1 Replace the numeric-argument test with a direct one, removing the command substitution
      that captures and compares `grep`'s exit status. Verify the alias still rejects a
      non-numeric argument and accepts a numeric one, in a throwaway repository.
- [ ] 3.2 Replace the two `declare` uses with plain assignments, since git invokes alias bodies
      under `sh`. Verify the resolved body contains no `declare` and the alias still resolves the
      current branch correctly.
- [ ] 3.3 Quote the remaining expansions in the body. Verify the resolved body is clean under
      `shellcheck -s sh` with the shebang and `"$@"` applied.

## 4. Add the analysis step

- [ ] 4.1 Add a step to the static-analysis job in `.github/workflows/ci.yml` that enumerates
      shell-prefixed git aliases with `git config -z --get-regexp`, and for each one strips the
      leading `!`, prepends `#!/bin/sh`, appends `"$@"` to the whole value, and runs
      `shellcheck -s sh`. Verify by pushing and confirming the step runs and passes.
- [ ] 4.2 Verify the step handles a multi-line alias body without corrupting it: confirm `mpr`,
      whose resolved value contains newlines, is analysed as one script and produces no findings
      caused by the extraction itself.
- [ ] 4.3 Verify the step catches a real regression: temporarily unescape a quote in one alias,
      confirm the step goes red and names that alias, then revert.
- [ ] 4.4 Verify the step covers a new alias without registration: temporarily add a shell alias
      with an unquoted expansion, confirm the step goes red, then revert.

## 5. Build the alias behaviour suite

- [ ] 5.1 Add `tests/gitaliases.bats` with a helper that creates a throwaway repository, includes
      the repository's `.gitaliases`, seeds an initial commit, and removes the repository in
      teardown. Verify the helper leaves nothing behind by checking the temporary directory is
      gone after a run, and that no repository outside it is touched.
- [ ] 5.2 Move the existing `cc` end-to-end test out of `tests/load.bats` into the new file,
      leaving `load.bats` covering only whether each tool accepts its configuration. Verify both
      files pass and the `cc` coverage is preserved, including that it still proves the `[pretty]`
      custom format and the alias are present together.
- [ ] 5.3 Add an end-to-end test for `cm`: commit with a known message in a throwaway repository
      and assert the alias finds it. Verify the test fails if the alias is removed.
- [ ] 5.4 Add an end-to-end test for `lrb` against a local bare repository acting as `origin`,
      asserting it lists that remote's heads. Verify it covers the defaulted argument by
      invoking it with no argument as well as with an explicit remote.
- [ ] 5.5 Add an end-to-end test for `get` that fetches and checks out a branch whose name
      contains a space, asserting the branch is checked out as a single ref. Verify this test
      fails against the pre-fix alias and passes after it, proving it detects the quoting bug
      rather than merely passing.
- [ ] 5.6 Add an end-to-end test for `mpr` against a throwaway repository containing a synthetic
      `refs/pull/N/head` reference: assert it merges that ref onto the expected branch and amends
      the message with the closing reference. This is the destructive alias, so it is verified by
      running it rather than by reading it.
- [ ] 5.7 Add a check that every alias defined in `.gitaliases` has a corresponding test, derived
      from the configuration rather than a hand-written list. Verify it fails when an alias is
      added without a test, by temporarily adding one.
- [ ] 5.8 Confirm the suite is green and consistent: `bats tests/` passes, and the aliases named
      in `README.md` match those defined in `.gitaliases`.
