## Why

There are two ways to get these dotfiles onto a machine, and they do not agree about what
"installed" means.

The normal way is the [mac-dev-setup](https://github.com/jasonheecs/mac-dev-setup) Ansible
playbook. It clones this repository and creates ten symlinks in your home directory. The other
way is `tests/install.sh` in this repository. It creates seven.

The three it skips are not an accident in one direction. Two of them are *deliberately* skipped,
with written reasons — and Ansible links them anyway.

**One of those reasons is just wrong.** `install.sh` skips `.gitignore` because, it says, the
file "applies to the repository itself." It does not. Look at `.gitconfig`:

```ini
[core]
    excludesfile = ~/.gitignore
```

That is git's *global* ignore file — the one that applies to every repository you work in. The
name made it look repo-local, and the reason was written from the name instead of from the
config that points at it.

Here is the bad part. If you install standalone on a fresh machine, `~/.gitignore` never gets
created. Git does not complain about a missing ignore file. It just acts like the file is empty.
Your global ignore rules stop working and nothing tells you. This has never bitten you because
Ansible linked the file back in March.

**The third missing file is in a subfolder.** `.claude/CLAUDE.md` lives one level down.
`install.sh` cannot make a link in a subfolder at all. And the check that is supposed to catch
"you added a dotfile and forgot to install it" only looks at the top level, so the file is
invisible to the installer *and* to its own safety net.

On top of all that, the installer lives in `tests/`. That is where you look for tests, not for
the thing a new machine runs first.

The Ansible repository is off-limits for edits, so this repository does all the moving.

See the [install paths diagram](design.md#the-two-install-paths) for how the two routes converge.

## What Changes

- Move the installer from `tests/install.sh` to `install.sh` at the top of the repository, and
  update the three places that point at the old path.
- Grow the installer's list from seven files to ten, so it matches Ansible: add `.gitignore`,
  `.osx`, and `.claude/CLAUDE.md`.
- Correct the record on `.gitignore`. It is the global ignore file that `.gitconfig` points at,
  and it belongs in your home directory.
- Link `.osx`, but still never run it. Those are two different things. The existing rule is about
  *running* it, and that rule does not change at all.
- Teach the installer to make links inside subfolders, creating the folder if it is missing.
- Widen the "did you forget to install this?" check so it looks at every tracked dotfile, not
  just the ones at the top level. That is what let `.claude/CLAUDE.md` slip through.
- Shrink the skip list to exactly one file, `.github/workflows/ci.yml`, which configures this
  repository's own CI and has no business in your home directory.
- Write a note next to the file list saying it mirrors `dotfiles_files` in the Ansible
  repository, so the next reader knows the list is not a free choice and knows where to compare.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `dotfiles-bootstrap`: two rules change and one is added.
  - *Managed dotfiles are linked into the home directory* (modified) — one part currently says
    the macOS defaults script and `.gitignore` are deliberately not linked. Both get linked now,
    so that part gets rewritten around the one file that really is skipped. It also gains a case
    for making a link inside a folder that does not exist yet.
  - *Every tracked dotfile is accounted for by the bootstrap* (modified) — widens from "tracked
    at the top level" to "tracked anywhere", closing the gap that let `.claude/CLAUDE.md` go
    unnoticed.
  - *Standalone installation matches the provisioned result* (added) — there is no rule today
    saying the two install routes should agree, which is why they drifted apart.

## Impact

- `tests/install.sh` → `install.sh` — moved, list extended, subfolder linking added.
- `tests/invariants.bats` — points at the old path in two places, and its check widens to
  subfolders.
- `tests/bootstrap.bats` — runs the installer, so it follows the move and covers the new files.
- `.github/workflows/ci.yml` — its fresh-machine step calls the old path.
- `README.md` — the Setup section points at `tests/install.sh` and lists seven manual commands.
- Three more files get linked into your home directory on a standalone install. On a machine
  Ansible already set up, all three are already links to the same targets, so the installer says
  "unchanged" and does nothing.
