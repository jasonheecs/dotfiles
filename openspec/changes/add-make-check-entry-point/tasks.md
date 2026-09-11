## 1. Create the entry point

- [x] 1.1 Add a `Makefile` at the repository root with one target per check and an aggregate
      `check` target depending on them. Verify each target runs its check on its own, and that
      `make check` runs all of them.
- [ ] 1.2 Add a `help` target listing the available targets with a one-line description each, and
      make it the default target so a bare `make` explains itself. Verify `make` and `make help`
      both print the list.
- [ ] 1.3 Make the aggregate report the behavioural suite as skipped, with a reason, when the
      macOS tooling it needs is absent, rather than failing. Verify by running the aggregate with
      that tooling unavailable and confirming it reports a skip and continues.
- [ ] 1.4 Confirm no target installs software. Verify by reading the recipes and checking that
      provisioning is absent from all of them.

## 2. Point the automation at the same definitions

- [ ] 2.1 Replace the behavioural job's inline commands in `.github/workflows/ci.yml` with its
      target invocation. Verify by pushing and confirming the job passes and its log shows the
      same commands running.
- [ ] 2.2 Replace each lint job's inline commands with its target invocation. Verify each job
      still passes and each still reports under its own check name.
- [ ] 2.3 Verify the definitions are genuinely shared: change a flag in one target, confirm the
      corresponding CI job picks it up without the workflow being edited, then revert.
- [ ] 2.4 Verify a check cannot exist without a target: confirm every job's step invokes a
      target, so a check added to CI with no target has nothing to call.

## 3. Handle the formatting interaction

- [ ] 3.1 Add a `Makefile` section to `.editorconfig` preserving tab indentation, since `make`
      requires tabs in recipes and the repository-wide setting is spaces. Verify the formatting
      check passes against the `Makefile` and that `make check` still runs.

## 4. Document the single command

- [ ] 4.1 Replace the command list in the README's Testing section with the aggregate command,
      keeping the provisioning step alongside it as a separate, explicit action. Verify by
      following the README from a clean shell and getting a complete run.
- [ ] 4.2 Record in `README.md` that the aggregate is a strong signal rather than a guarantee,
      because tool versions and platforms still differ between a local run and the automation.
      Verify a reader can tell what a clean local run does and does not prove.
