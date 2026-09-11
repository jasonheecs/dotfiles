## 1. Create the entry point

- [x] 1.1 Add a `Makefile` at the repository root with one target per check and an aggregate
      `check` target depending on them. Verify each target runs its check on its own, and that
      `make check` runs all of them.
- [x] 1.2 Add a `help` target listing the available targets with a one-line description each, and
      make it the default target so a bare `make` explains itself. Verify `make` and `make help`
      both print the list.
- [x] 1.3 Make the aggregate report the behavioural suite as skipped, with a reason, when the
      macOS tooling it needs is absent, rather than failing. Verify by running the aggregate with
      that tooling unavailable and confirming it reports a skip and continues.
- [x] 1.4 Confirm no target installs software. Verify by reading the recipes and checking that
      provisioning is absent from all of them.

## 2. Point the automation at the same definitions

- [x] 2.1 Replace the behavioural job's inline commands in `.github/workflows/ci.yml` with its
      target invocation. Verify by pushing and confirming the job passes and its log shows the
      same commands running.
- [x] 2.2 Replace each lint job's inline commands with its target invocation. Verify each job
      still passes and each still reports under its own check name.

      Scope note: only the `editorconfig` job has a genuinely inline command to redirect.
      `shellcheck` and `actionlint` run their tool via GitHub Marketplace actions that install a
      pinned version and run the check in one atomic step — neither supports install-only mode,
      so there's no inline command to point at a target without replacing the action outright.
      Per the user's explicit decision this session, those two jobs are left unchanged; `lint-shell`
      and `lint-workflow` exist for local use only. See tasks 2.3/2.4 for the resulting scope.
- [x] 2.3 Verify the definitions are genuinely shared: change a flag in one target, confirm the
      corresponding CI job picks it up without the workflow being edited, then revert.

      Added `-verbose` to `lint-format`, pushed with `ci.yml` untouched: run 34565290227's
      `editorconfig` job log shows `editorconfig-checker -verbose` and the verbose "Adding ... to
      be checked" lines, proving CI picked up the flag with zero workflow changes. Reverted here.
      Demonstrated against `lint-format`/`editorconfig`, not shellcheck/actionlint — see 2.2's
      scope note.
- [x] 2.4 Verify a check cannot exist without a target: confirm every job's step invokes a
      target, so a check added to CI with no target has nothing to call.

      Holds for `test` (`run: make test`) and `editorconfig` (`run: make lint-format`). Does
      **not** hold for `shellcheck` (marketplace action, plus a `tests/lint-gitaliases.sh` step
      left untouched alongside it) or `actionlint` (marketplace action) — both jobs were left
      unchanged per the scope decision recorded in 2.2. For those two, a check added to CI without
      a target would still have nothing to call structurally, but an *existing* check's drift from
      its `lint-shell`/`lint-workflow` target's definition would go undetected, since CI doesn't
      run through those targets at all. This narrows the spec's "every job's step invokes a
      target" scenario to 2 of 4 checks. Now recorded formally: design.md's diagram marks the two
      unrouted jobs with dashed edges and carries a "Two jobs keep their marketplace actions"
      decision, and the delta spec's requirement distinguishes invoked from matched definitions.
      See task 2.5 for the gap this left in `lint-shell`.

- [x] 2.5 Close the gap the exemption leaves in `lint-shell`: discover the scripts to analyse
      instead of listing them, matching how CI's action selects files. Verify a newly added script
      is analysed with nothing registering it, and that the target still passes.

      The enumerated list omitted `tests/lint-gitaliases.sh`, which CI's action checks by pattern,
      so a ShellCheck finding there would have passed `make check` and failed CI. Now
      `shellcheck $(git ls-files '*.sh' '*.bash' '*.bats' '.osx')`, which resolves to exactly the
      set the action finds. Verified: an unregistered probe script's SC2086 failed the target
      (`make: *** [lint-shell] Error 1`), and the target passes clean once removed.

## 3. Handle the formatting interaction

- [x] 3.1 Add a `Makefile` section to `.editorconfig` preserving tab indentation, since `make`
      requires tabs in recipes and the repository-wide setting is spaces. Verify the formatting
      check passes against the `Makefile` and that `make check` still runs.

      Already satisfied: the `[{Makefile,makefile,GNUmakefile,*.mk}]` section with
      `indent_style = tab` was added in `4ecd628`, before this change. No new edit needed;
      verified `editorconfig-checker Makefile` passes clean and `make check` runs.

## 4. Document the single command

- [x] 4.1 Replace the command list in the README's Testing section with the aggregate command,
      keeping the provisioning step alongside it as a separate, explicit action. Verify by
      following the README from a clean shell and getting a complete run.
- [x] 4.2 Record in `README.md` that the aggregate is a strong signal rather than a guarantee,
      because tool versions and platforms still differ between a local run and the automation.
      Verify a reader can tell what a clean local run does and does not prove.
