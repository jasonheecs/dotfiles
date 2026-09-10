## Why

The file that runs every check in this repository is the one file nothing checks.

`.github/workflows/ci.yml` is the recipe GitHub follows on every push. It decides which checks
run. If it has a typo in an action name, or a broken expression, or a step that quietly never
runs, then every other guarantee here gets weaker — and nothing would tell you. The shell linter
finds scripts by their shebang line. A workflow is YAML, so it never gets looked at.

There is also shell code hiding inside it. The step that installs on a fresh machine is a `run:`
block with real commands in it, and the work already in progress adds more of those.

That makes three separate hiding places for shell in this repository:

```
.sh / .bash / .bats files   -> the shell linter finds these
git alias values            -> a separate check finds these
workflow run: blocks        -> nothing finds these
```

`actionlint` handles both halves of the problem. It checks the workflow itself, and it runs
ShellCheck over every `run:` block for you.

See the [coverage diagram](design.md#what-covers-what) for how this fits with the other checks.

## What Changes

- Add an `actionlint` job that checks every workflow file in the repository.
- Get the shell inside `run:` blocks checked for the first time, using the ShellCheck integration
  `actionlint` already has built in.
- Add `actionlint` to the test tooling list so you can run it locally with one command, like the
  other checks.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `dotfiles-verification`: one rule is added.
  - *Workflow definitions are validated* (added) — there is no rule today about whether this
    repository's own automation is correct. The existing linting rule is about shell scripts
    found as files, and no reading of it reaches a YAML workflow or the shell tucked inside one.

## Impact

- `.github/workflows/ci.yml` — gains a job, and becomes something that job checks.
- `tests/Brewfile` — gains `actionlint`.
- `README.md` — the Testing section lists what runs; this adds to it.
- No dotfile that gets linked into your home directory is touched. This is entirely about how the
  repository checks itself.
