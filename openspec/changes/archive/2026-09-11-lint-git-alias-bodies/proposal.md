## Why

`.gitaliases` contains about fifty lines of shell code, and nothing checks it.

Every other shell script here is about to get checked by a linter — a program that reads code and
flags likely mistakes. But that linter finds scripts by looking for a shebang line at the top of
a file. This code is not in a file. It is inside quoted strings in a git config file, so the
linter will never find it.

That is not a theoretical worry. Three of the six aliases are already broken, in a way you cannot
see by reading the file.

**Here is the trap.** In a git config file, a `"` marks the end of a value. If you want a quote
*inside* the value, you have to write `\"`. Otherwise git throws it away. So this:

```
remote="${1:-origin}";
git ls-remote --heads "$remote";
```

is stored by git as this:

```
remote=${1:-origin};
git ls-remote --heads $remote;
```

The quotes are gone. `mpr` escapes its quotes properly. `lrb`, `retag`, and `get` do not.

Without quotes, the shell splits any value containing a space into separate words. So
`git get "feature/my branch"` does not fetch one branch with a space in the name. It tries to
fetch two things, both wrong.

The written rules for this repository already say a git alias gets tested end to end. Exactly one
alias is actually tested — and it is the one that takes no arguments, so it could never have
caught this.

See the [extraction diagram](design.md#how-the-check-sees-the-code) for how the new check reaches
code that lives inside a config value.

## What Changes

- Delete the `retag` alias. It has gone unused for a long time. Deleting shell nobody runs beats
  repairing it.
- Fix the quote escaping in `lrb` and `get`, so the values they hand to git stay quoted.
- Rewrite `mpr`. Its check for "is this argument a number?" runs `grep`, throws away the output,
  prints grep's exit code into a command substitution, and then compares that number — where
  `grep -q` does the same job in one step. It also uses `declare`, which is a bash feature, in
  code that git runs with plain `sh`.
- Add a check that lints the alias code. It works by asking git for each alias *as git stores it*,
  then running the linter on that. It checks what actually runs, not what the file looks like —
  which is exactly the difference these three bugs were hiding in.
- Write an end-to-end test for every alias, in a new `tests/gitaliases.bats`. Each one gets run
  against a throwaway repository and checked. One of them uses a branch name with a space in it,
  which is the case that would have caught all three bugs years ago.
- Add a check that you cannot add an alias without adding a test for it, worked out from the
  config rather than a hand-written list.
- Update the alias list in `README.md`.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `dotfiles-verification`: two rules are added, none changed.
  - *Shell embedded in configuration is analysed* (added) — there is no rule covering shell that
    lives inside a config value. The existing linting rule is about shell *scripts*, found as
    files, and no reading of it reaches `.gitaliases`.
  - *Every git alias is exercised end to end* (added) — right now a single alias gets run, tucked
    under a rule about whether tools load their config. Actually testing the aliases is a
    different concern and gets its own rule, covering arguments and the destructive alias.

  The existing *Each tool accepts its own configuration* rule keeps its one alias check. The test
  moves to the new file, but the rule stays put — it is a legitimate check that the alias and the
  output format it depends on are both still there.

## Impact

- `.gitaliases` — one alias deleted, two fixed, one rewritten.
- `.github/workflows/ci.yml` — the linting job gains a step. **This change needs
  `add-static-analysis-and-formatting-checks` to land first**, because that is what creates the
  job this step goes into.
- `tests/gitaliases.bats` — new file holding the alias tests.
- `tests/load.bats` — loses its alias test, which moves to the new file.
- `README.md` — the alias list names `retag`.
- Anyone with `git retag` in muscle memory loses it. That is the point of deleting it.
