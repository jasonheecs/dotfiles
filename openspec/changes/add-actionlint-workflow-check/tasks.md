## 1. Establish the baseline

- [x] 1.1 Install `actionlint` locally and run it against the repository, recording every finding
      against the current `.github/workflows/ci.yml`. Verify by capturing the output, so the
      change starts from a known state rather than discovering it in CI.
- [x] 1.2 Resolve each finding from 1.1 — fix it, or suppress it with a stated reason. Verify a
      local run exits 0 with no output.

## 2. Add the job

- [x] 2.1 Add a job named `actionlint` to `.github/workflows/ci.yml`, running on `ubuntu-latest`,
      triggered by the existing `push` and `pull_request` events, with a pinned validator
      version. Verify by pushing and confirming a distinctly-named check appears and passes.
- [x] 2.2 Verify it catches a structural error: temporarily set an unknown `with:` input on a
      step (e.g. `actions/checkout@v4`, a version actionlint has bundled metadata for), confirm
      the check goes red and names the step, then revert. (`actionlint` does not verify that a
      referenced action or version actually exists — confirmed empirically and in its docs — so
      an unresolvable reference does not produce a finding; an unknown input on a known action
      does.)
- [x] 2.3 Verify it catches shell inside a step: temporarily introduce an unquoted expansion into
      a `run:` block, confirm the check goes red and reports the finding against that step, then
      revert. This is the blind spot the change exists to close, so it is verified directly.
- [ ] 2.4 Verify discovery is automatic: temporarily add a second workflow file containing a
      known error, confirm the check goes red naming that file without anything being registered,
      then revert.
- [x] 2.5 Verify the job is independent: confirm from the run's timing that it starts in parallel
      with the other jobs and is not gated on any of them.

## 3. Make it available locally

- [ ] 3.1 Add `actionlint` to `tests/Brewfile`. Verify with `brew bundle --file=tests/Brewfile`
      followed by `command -v actionlint`.
- [ ] 3.2 Update the Testing section of `README.md` to include workflow validation in the list of
      what runs and how to run it locally. Verify by following the README's own instructions from
      a clean shell and getting a clean run.
- [ ] 3.3 Record in `README.md` that a workflow broken badly enough not to parse will surface as
      the automation declining to run rather than as a validation finding, and that running the
      validator locally is what catches that case. Verify a reader can tell from the README what
      a green result does and does not prove.
