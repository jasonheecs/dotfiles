## Context

See [proposal.md — Why](proposal.md) for motivation.

The constraints that shape the approach:

- **Git runs alias bodies as `sh -c '<body> "$@"' <name> <args>`.** Two consequences: the
  dialect is POSIX `sh`, not bash; and the body is invoked with the user's arguments appended.
  Both matter to the check, in ways that are easy to get wrong.
- **Git's config parser rewrites the code before the shell sees it.** Unescaped `"` delimits a
  value, `\n` becomes a real newline, and line continuations collapse to spaces. Reading
  `.gitaliases` as text tells you what was written; only `git config --get` tells you what runs.
- **`mpr`'s resolved value contains real newlines**, from the `\n\n` in its commit message. Any
  extraction that works line-by-line will corrupt it.
- **Baseline, with `retag` removed:** `cc` and `cm` are clean. `lrb` has one unquoted expansion,
  `get` has two, and both stem purely from the escaping bug. `mpr` has findings across quoting,
  POSIX portability, and a needlessly indirect numeric test.
- **`/bin/sh` on macOS is bash in POSIX mode**, which is why `declare` and `&>` work here
  despite not being POSIX. They would fail under a stricter `sh`.
- **The pending `add-static-analysis-and-formatting-checks` change creates the CI job** this
  work adds a step to, and finds scripts by shebang — a mechanism that structurally cannot reach
  a config value.

## How the check sees the code

```mermaid
flowchart TD
    file[".gitaliases (source text)"] -->|read as text| wrong["what the file shows<br/>quotes present"]
    file -->|git config -z --get-regexp| parsed["what git stores<br/>quotes discarded"]

    wrong -.->|the bug hides here| gap[three aliases look correct<br/>and are not]

    parsed --> strip["strip leading !"]
    strip --> wrap["prepend #!/bin/sh<br/>append \"$@\" to the whole value"]
    wrap --> sc["shellcheck"]
    sc --> verdict{findings?}
    verdict -->|yes| red[job fails, names the alias]
    verdict -->|no| green[job passes]

    shebangdisc["shebang-based discovery<br/>(the pending shellcheck job)"] -.->|cannot reach| file
```

The left branch is how a person reads the file, and it is why the bug survived. The right branch
is what the check does.

## Goals / Non-Goals

**Goals:**

- Analyse the code git runs, not the text the file contains.
- Discover aliases from the configuration, so a new one is covered without registration.
- Produce no findings that are artefacts of the extraction itself.
- Leave behind a behavioural test that would have caught this class of bug without any linter.

**Non-Goals:**

- **Moving alias bodies into standalone scripts.** Git supports `git foo` resolving to a
  `git-foo` executable on `PATH`, which would put this shell in real files and remove the
  escaping problem at its root. Rejected here — see Decisions.
- **Auditing what the aliases do.** `mpr`'s workflow is unchanged; only its implementation is
  corrected.
- **Extending analysis to other embedded shell.** `.osx` and the workflow's `run:` blocks are
  separate concerns.

## Decisions

### Delete `retag` rather than fix it

Unused for a long time, and it carried two of the escaping bugs plus a non-POSIX `&>`. Removing
it is less code to own and one fewer thing to verify.

*Consequence:* `README.md`'s alias list changes, and anyone with it in muscle memory loses it.

### Extract with `git config -z --get-regexp`, not by parsing the file

The whole point is to analyse what git resolved. `-z` makes the output null-delimited, which is
what keeps `mpr`'s embedded newlines from being mistaken for record boundaries.

*Alternative considered:* pattern-matching the alias bodies out of `.gitaliases` with `sed`, the
way `invariants.bats` extracts the installer's arrays. Rejected — that reproduces the reading
that hid the bug, and would report the discarded quotes as present.

### Append `"$@"` to the resolved value, and to the value rather than to each line

Git invokes the body with the user's arguments appended. Analysing the body alone makes
ShellCheck conclude that `f` is never called with arguments, which produces SC2119 and SC2120 on
every alias — twelve false findings across six aliases, enough noise to make the check look
unusable.

Appending per-line rather than per-value is the other trap: on `mpr`, whose resolved value is
multi-line, a line-oriented append lands `"$@"` inside the quoted commit message and generates
three further bogus findings. Both traps were hit while proving this approach out, and both
disappear once the append is applied once, at the end of the whole value.

### Prepend `#!/bin/sh` rather than excluding SC2148

Both silence the missing-shebang complaint. The shebang additionally declares the dialect
in-band, so the check does not depend on a `--shell` flag staying in step with a suppression
list.

### Analyse as `sh`, and fix the portability findings rather than silence them

Analysing as bash would make `declare` and `&>` acceptable and produce a green result. But git
invokes `sh`, so that is choosing a dialect to get the answer we want. The violations are
one-line fixes that make the aliases genuinely portable, so fix them.

### Keep the bodies in `.gitaliases` rather than moving them to `git-*` scripts

Standalone `git-foo` executables on `PATH` would put this shell into ordinary files, covered by
ordinary shebang discovery, with no escaping layer to get wrong. It is the better architecture.

Rejected for now because it collides with work already in flight: the standalone installer is
being aligned so that it and the `mac-dev-setup` playbook produce identical home directories.
Introducing a directory of executables that has to be on `PATH` would mean either a new manifest
entry the playbook does not have — reopening the divergence that change exists to close — or a
`PATH` requirement that only one of the two install paths satisfies.

*Revisit* if the alias bodies keep growing, and reconsider it together with the playbook rather
than in this repository alone.

### The alias behaviour suite gets its own file, and the existing test moves into it

The bats suite is organised in layers — parse, config loading, invariants, real shell — and each
file's header says which layer it is. The one alias test currently sits in `load.bats`, whose
stated job is "does each tool actually accept its config?". Invoking an alias and asserting on
what it did is not that, and six such tests would drown the file's actual purpose.

A new `tests/gitaliases.bats` holds the behaviour suite, and the existing `cc` test moves into
it. `load.bats` keeps only the two config-parsing checks and the editor and multiplexer ones.

The spec does not follow the test across. A MODIFIED block replaces a requirement wholesale, so
dropping a scenario from one requirement to re-home it in another is not something the delta
format expresses — and archive rejects the attempt rather than silently losing it. The existing
"A git alias resolves end to end" scenario therefore stays put, which is defensible on its own
terms: it asserts that the alias and the `[pretty]` format it depends on are still present
together, which is a coherence property of the configuration rather than a behavioural one. The
new requirement covers behaviour.

*Alternative considered:* keep growing `load.bats`. Rejected — it is the file that would need a
section comment to stay readable, which the repository's conventions treat as a signal to split.

### Static analysis and behavioural coverage are both needed, for different reasons

ShellCheck would have found the unquoted expansions. It would not have found an alias that lints
cleanly and does the wrong thing, and it cannot confirm that `[pretty] custom` still exists for
`cc` to depend on. Conversely, a behavioural test with a space in the argument would have caught
all three quoting bugs without any linter at all.

Neither subsumes the other, so this change adds both, and the "every alias has a test" check
exists so the behavioural half cannot quietly fall behind the alias list the way it already has.

### The check is a step in the static-analysis job, not a bats test

It is ShellCheck, failing for the same reason and fixed by the same discipline as the job's
other step. The pending change deliberately moved ShellCheck out of the bats suite; putting a
new use of it back there would undo that.

*Consequence:* a hard ordering dependency — `add-static-analysis-and-formatting-checks` creates
the job, so it must land first. Stated in the proposal rather than engineered around.

## Risks / Trade-offs

**`mpr` is destructive and is being rewritten** → It rebases, force-creates branches,
`branch -D`s, and amends commits. The quoting fixes are mechanical, but the numeric-argument test
is being restructured, and a mistake there changes which branch the workflow acts on. It gets its
own task and its own verification against a throwaway repository with a synthetic
`refs/pull/N/head`, rather than riding along with the two simple escaping fixes.

**The escaping is easy to get wrong again** → The fix is `\"` where a quote is wanted, and
nothing about the file makes that obvious to the next reader. The check is the mitigation: a
regression fails CI rather than waiting to be noticed by a branch name with a space in it.

**ShellCheck may object to idioms that are fine in an alias** → The `f() { ...; }; f` wrapper is
conventional for git aliases and is not something ShellCheck sees often. The `"$@"` handling
resolves the two findings it produces; if others surface, they are suppressed per-alias with a
stated reason, following the same discipline the pending change uses.

**Removing `retag` is not reversible from muscle memory** → Trivial to restore from history if
it turns out to be wanted.

## Migration Plan

No deployment. `.gitaliases` is symlinked into `$HOME`, so the change takes effect the next time
a git alias is invoked — there is nothing to reload.

Ordering: `add-static-analysis-and-formatting-checks` first, since it creates the job. Within
this change, the alias fixes land before the check, or the check is red on arrival.

Rollback is reverting the commits.

## Open Questions

None.
