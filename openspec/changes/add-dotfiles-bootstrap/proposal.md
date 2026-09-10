## Why

Setting up a new machine from this repo means reading the README and copy-pasting six
`ln -sf` commands by hand. That works right up until the list is wrong — and it already is.
`.tmux.conf` was added in commit `ee60794` and never made it into the README, so it appears
in neither the contents table nor the setup commands. On this machine it works only because
it was linked by hand. Follow the README on a fresh laptop today and you get no tmux config,
with nothing to tell you.

The deeper problem is that instructions written as prose can't be checked. There is no way
to test a paragraph. Turning setup into a script makes it something a machine can run, and
therefore something a machine can verify — so the next file that gets added can't quietly go
missing.

## What Changes

- **Add an installer** (`tests/install.sh`) — a bash script that creates the symlinks for
  you. Safe to run twice, backs up any real file it would otherwise overwrite, and has a
  `--dry-run` mode so you can see what it would do before it does anything.
- **Add a coverage check** — a test that reads the list of dotfiles tracked in the repo and
  fails if any of them is neither installed by the script nor recorded as a deliberate
  skip. This is the check that would have caught the `.tmux.conf` gap the day it appeared.
- **Add installer tests** — run the script against a throwaway home directory and confirm
  the links land, a second run changes nothing, an existing file gets backed up, and
  `--dry-run` writes nothing at all.
- **Add a fresh-machine CI step** — run the installer on a clean macOS runner and then open
  a shell, proving end to end that a new machine can be set up from a checkout.
- **Fix the README drift** — add `.tmux.conf` to the contents table and to the `ln -sf`
  block.

No dotfile changes behaviour. The README's copy-paste setup block stays, so the existing
manual path keeps working exactly as before.

See the [architecture diagram in design.md](design.md#architecture) for how the installer,
its tests, and CI fit together.

## Scope: the second half of a deliberate split

This is the companion to `add-dotfiles-test-harness`, which covers verifying the dotfiles
that already exist (syntax, tool-load, shell behaviour, CI).

**This change depends on that one** for the bats tooling — `tests/Brewfile` and
`tests/helpers/common.bash` — so land the harness first. If you'd rather reverse the order,
this change has to introduce those two files itself.

The dead `ggl` alias is deliberately *not* here. It moved to the harness change, because the
alias-sanity check that catches it lives there and would otherwise land failing.

## Capabilities

### New Capabilities

- `dotfiles-bootstrap`: Installing the dotfiles onto a machine — which files get linked,
  what happens when something is already there, how to preview the result without touching
  anything, and how the repo proves the installer actually covers every file it should.

### Modified Capabilities

None. The coverage check is deliberately specified as part of `dotfiles-bootstrap` rather
than as a delta against `dotfiles-verification`: that capability does not exist in
`openspec/specs/` yet — it lives only as a delta inside the sibling change — so a delta
against it would create an archive-ordering dependency between the two changes for no
benefit. Coverage of the installer is a bootstrap concern anyway.

## Impact

**New files**

- `tests/install.sh` — the installer
- `tests/bootstrap.bats` — installer behaviour tests
- `tests/invariants.bats` — the coverage check (this change adds the file if the harness
  change has not already created it; otherwise it adds a test case to it)

**Modified files**

- `README.md` — add `.tmux.conf` to the contents table and the `ln -sf` block
- `.github/workflows/ci.yml` — add the fresh-machine install step

**No changes** to any dotfile.

**Depends on** `add-dotfiles-test-harness` for `tests/Brewfile`, `tests/helpers/common.bash`,
and the CI workflow this change extends.

**Known gap carried forward**

The installer lives in `tests/` and the README keeps its own hand-written `ln -sf` list.
Those are two separate copies of the same list and nothing checks that they agree, so CI can
be green while the README is wrong. This was a deliberate placement decision; the coverage
check protects the installer's list, not the README's.

**Safety note**

`.osx` writes macOS system settings and force-quits Dock, Finder, and Mail. The installer
must never run it, and neither must CI.
