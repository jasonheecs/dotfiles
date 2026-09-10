## Why

There used to be one command. You ran `bats tests/`, and if it passed, CI would pass too.

That is ending, on purpose. Checking the shell scripts, checking the formatting, checking the git
aliases, and checking the workflow are each moving into their own CI job. That is a good trade —
when something fails you see *which* check failed by name, instead of one red mark you have to
open and dig through.

But it costs something, and every one of those changes admits it: there is no longer a single
command you can run before pushing. Each of them says "we will document how to run the parts."

Documenting four commands is a worse answer than providing one. You have to remember the list.
And the list is only correct until someone adds a fifth check.

The sibling repository already solved this. `mac-dev-setup` has a `Makefile` you run things
through. This one has nothing, so moving between the two means remembering which is which.

See the [entry point diagram](design.md#one-definition-two-callers) for how the commands and the
CI jobs line up.

## What Changes

- Add a `Makefile` with one entry per check, plus one entry that runs all of them.
- Have each CI job call its matching entry instead of spelling out the commands. That way each
  command is written down in exactly one place.
- Add an entry that lists what you can run, so you can find out without opening the file.
- Replace the growing list of commands in the README with the single one.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `dotfiles-verification`: one rule is added.
  - *Verification can be run locally with one command* (added) — there is no rule about what it
    is like to run these checks yourself. The existing rules cover what gets checked and that CI
    runs it. The closest thing is a line saying the repository documents how to run each part by
    hand.

## Impact

- `Makefile` — new file at the top of the repository.
- `.github/workflows/ci.yml` — each job's commands get replaced by a call to the matching entry.
- `README.md` — the Testing section swaps its command list for the single command.
- **Ordering**: this should land after the changes that create the checks it wraps. A list built
  before those exist would be wrong on arrival.
- No dotfile that gets linked into your home directory is touched.
