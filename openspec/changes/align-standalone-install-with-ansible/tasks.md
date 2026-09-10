## 1. Relocate the installer

- [ ] 1.1 Move `tests/install.sh` to `install.sh` at the repository root, preserving its
      executable bit. Verify with `ls -l install.sh` showing mode 755 and
      `./install.sh --dry-run` still producing a plan.
- [ ] 1.2 Update the two path references in `tests/invariants.bats` and confirm the array
      extraction still finds entries. Verify by checking the extraction returns a non-empty list
      before asserting on it, so the test cannot pass vacuously against a wrong path.
- [ ] 1.3 Update `tests/bootstrap.bats` to invoke the new path. Verify with
      `bats tests/bootstrap.bats` passing.
- [ ] 1.4 Update the fresh-machine step in `.github/workflows/ci.yml` to the new path. Verify by
      pushing and confirming the step runs the installer and the shell check succeeds.
- [ ] 1.5 Confirm no reference to the old path survives anywhere in the repository, by searching
      the tree for `tests/install.sh` and finding no hits.

## 2. Extend the manifest to match the provisioning playbook

- [ ] 2.1 Add `.gitignore` and `.osx` to the installer's link list and remove them from the
      exclusion list. Verify against a sandbox home directory that both are created as links
      resolving to the repository files.
- [ ] 2.2 Reduce the exclusion list to `.github/workflows/ci.yml` with a reason stating it
      configures this repository's CI. Verify the existing check that every exclusion records a
      reason still passes.
- [ ] 2.3 Add a comment above the manifest recording that it mirrors `dotfiles_files` in
      `mac-dev-setup/default.config.yml`, and naming that file. Verify by reading the manifest
      and confirming a reader can locate the external list from it alone.
- [ ] 2.4 Confirm the installer's list and the playbook's list now contain the same paths, by
      comparing them by hand and noting the result. Verify the only difference is the playbook's
      duplicate `.claude/CLAUDE.md` entry, which is harmless and out of scope.

## 3. Support nested link targets

- [ ] 3.1 Teach the installer to create a link target's parent directory when it does not exist,
      applied per manifest entry so any entry containing a slash works. Verify against a sandbox
      home directory with no `.claude` directory that the directory is created and the link lands
      inside it.
- [ ] 3.2 Add `.claude/CLAUDE.md` to the manifest. Verify against a sandbox home that it is
      linked to the repository file, and that `~/.claude` itself is a real directory rather than
      a link into the repository.
- [ ] 3.3 Verify the nested case is idempotent: run the installer twice against the same sandbox
      home and confirm the second run reports the entry unchanged and creates no backup.
- [ ] 3.4 Verify dry-run mode covers nested entries: run with `--dry-run` against a sandbox home
      with no `.claude` directory and confirm the directory is not created and the plan names the
      link it would make.

## 4. Widen the accounting check

- [ ] 4.1 Change the tracked-dotfile enumeration in `tests/invariants.bats` to include files
      below the repository root, not only those at it. Verify the enumeration returns eleven
      files — nine at the root, plus `.claude/CLAUDE.md` and `.github/workflows/ci.yml`.
- [ ] 4.2 Verify the widened check actually fails on an unaccounted-for nested file: temporarily
      track a dotfile in a subdirectory without adding it to either list, confirm the check fails
      and names it, then revert.
- [ ] 4.3 Verify the check passes against the final manifest, with ten installed entries and one
      exclusion accounting for all eleven tracked dotfiles.

## 5. Document both paths

- [ ] 5.1 Update the Setup section of `README.md` for the new installer path and the extended
      file list, replacing the seven hand-written `ln` commands with the current ten entries.
      Verify by following the README's manual instructions against a sandbox home and getting the
      same links the installer produces.
- [ ] 5.2 Add a short note to `README.md` explaining that these dotfiles are normally installed by
      the `mac-dev-setup` playbook, that the installer is the standalone route, and that both
      produce the same links. Verify a reader can tell from the README alone which route to use
      and that the two are equivalent.
