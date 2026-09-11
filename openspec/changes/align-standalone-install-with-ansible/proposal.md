## Why

There are two ways to get these dotfiles onto a machine, and they do not agree about what
"installed" means.

The normal way is the [mac-dev-setup](https://github.com/jasonheecs/mac-dev-setup) Ansible
playbook. It clones this repository and links ten distinct files into your home directory. The
other way is `tests/install.sh` in this repository. It links seven.

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

**Two more files at the top look like dotfiles but are not.** `.editorconfig` and
`.editorconfig-checker.json` arrived later, to configure this repository's own formatting check.
In a dotfiles repository, a dot-file at the top reads as "this belongs in your home directory",
and neither of these did.

On top of all that, the installer lives in `tests/`. That is where you look for tests, not for
the thing a new machine runs first.

See the [install paths diagram](design.md#the-two-install-paths) for how the two routes converge.

## What Changes

- Move the installer from `tests/install.sh` to `install.sh` at the top of the repository, and
  update the places that point at the old path.
- Grow the installer's list from seven files to eleven: add `.gitignore`, `.osx`,
  `.claude/CLAUDE.md`, and `.editorconfig`.
- Correct the record on `.gitignore`. It is the global ignore file that `.gitconfig` points at,
  and it belongs in your home directory.
- Link `.osx`, but still never run it. Those are two different things. The existing rule is about
  *running* it, and that rule does not change at all.
- Teach the installer to make links inside subfolders, creating the folder if it is missing.
- Give the installer a way to print the files it manages, so the tests can ask it instead of
  reading its source code with `sed` — which, as written, cannot even read a path with a slash in
  it.
- **Delete `.editorconfig-checker.json`.** Its single setting has an identical command-line flag,
  so the file can go and the flag can be passed where the checker is run. One less dot-file at the
  top that was never yours.
- **Link `.editorconfig` instead of hiding it.** It cannot move — the EditorConfig standard fixes
  both its name and the fact that tools look for it by walking up from the file being edited — so
  the honest answer is to make it serve double duty, exactly like `.gitignore` already does. It
  keeps configuring this repository *and* becomes your default for projects that do not bring
  their own. Before that, it gains tab rules for Makefiles and Go, so being a global default
  cannot break the formats that require tabs.
- **Drop the "did you forget to install this?" check.** It made you maintain a second list every
  time you added or removed a dotfile, and that list existed for no other reason. Adding a dotfile
  to a dotfiles repository should be cheap. The written reasons stay, as a comment next to the
  list.

After this, twelve dotfiles are tracked: eleven are linked, and one — `.github/workflows/ci.yml`
— is deliberately not.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `dotfiles-bootstrap`: one rule changes, one is added, one is removed.
  - *Managed dotfiles are linked into the home directory* (modified) — one part currently says
    the macOS defaults script and `.gitignore` are deliberately not linked. Both get linked now,
    so that part gets rewritten around the one file that really is skipped. It also gains a case
    for making a link inside a folder that does not exist yet, and two cases for the formatting
    declaration now doing double duty.
  - *The managed file list is readable without parsing the bootstrap* (added) — the tests
    currently read the installer's source text to find out what it installs, which breaks on any
    path containing a slash.
  - *Every tracked dotfile is accounted for by the bootstrap* (removed) — see the reason and
    migration note in the spec delta.

## Impact

- `tests/install.sh` → `install.sh` — moved, list extended, subfolder linking added, exclusion
  arrays replaced by a comment, and a way to print the list added.
- `tests/invariants.bats` — points at the old path, and loses both of its bootstrap checks.
- `tests/bootstrap.bats` — runs the installer, so it follows the move, and asks the installer for
  its file list rather than repeating it.
- `tests/helpers/common.bash` — unchanged, but named here because the shellcheck file list moves
  with the installer.
- `.editorconfig` — gains tab rules for Makefiles and Go, and is now linked into your home
  directory.
- `.editorconfig-checker.json` — deleted.
- `.github/workflows/ci.yml` — its fresh-machine step calls the old path, and its formatting step
  needs the flag that replaces the deleted config file.
- `README.md` — the Setup section points at `tests/install.sh` and lists seven manual commands.
- **Outside this repository**: `dotfiles_files` in `mac-dev-setup/default.config.yml` needs
  `.editorconfig` added by hand, or the two routes differ by that one file. Nothing here can
  detect that, and nothing here changes it.
- Four more files get linked into your home directory on a standalone install. On a machine
  Ansible already set up, three of them are already links to the same targets, so the installer
  says "unchanged" and does nothing. Only `~/.editorconfig` is genuinely new.
