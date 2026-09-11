## 1. Relocate the installer

- [x] 1.1 Move `tests/install.sh` to `install.sh` at the repository root, preserving its
      executable bit, and drop the `/..` from its `REPO_ROOT` so it still resolves to the
      repository. Verify the file is executable and that `--dry-run` against a sandbox home
      names link targets inside that sandbox, not one directory above the repository.
- [x] 1.2 Update every reference to the old path: `tests/invariants.bats`,
      `tests/bootstrap.bats`, `.github/workflows/ci.yml`, and `README.md`. Verify by searching
      the tree for the old path and finding no hits outside `openspec/changes/archive/`.
- [x] 1.3 Verify the suite still passes against the moved installer with `bats tests/`, and that
      `shellcheck` over the repository's bash-family files is clean at the new path.

## 2. Remove the accounting check

- [x] 2.1 Delete both bootstrap checks from `tests/invariants.bats` — the one asserting every
      excluded file records a reason, and the one asserting every tracked root dotfile is
      installed or excluded — along with the array-extraction helper they share. Verify the file
      still parses, that only the alias check remains, and that its header comment already
      describes what is left.

## 3. Make the formatting declaration safe as a global default

- [x] 3.1 Add tab-indentation sections to `.editorconfig` for Makefiles and Go, so serving as a
      home-directory default cannot force spaces on formats that require tabs. Verify
      `editorconfig-checker` still reports the repository clean, and that a scratch Makefile
      indented with tabs outside any other declaration is accepted rather than flagged.

## 4. Extend the manifest and retire the exclusion arrays

- [ ] 4.1 Replace `EXCLUDED_FILES`, `EXCLUDED_REASONS`, and their print loop with a short comment
      recording what is deliberately not linked and why, and remove the bash 3.2 note that only
      justified the parallel-array shape. Verify the installer still runs against a sandbox home
      and no longer prints exclusion lines.
- [ ] 4.2 Add `.gitignore`, `.osx`, `.editorconfig`, and `.claude/CLAUDE.md` to the link list,
      ordered to match `dotfiles_files` so the two compare line by line, and add a comment above
      it naming `mac-dev-setup/default.config.yml` as the list it mirrors. Verify against a
      sandbox home that each newly added entry is created as a link resolving to the repository
      file.
- [ ] 4.3 Compare the installer's list against the playbook's by hand and note the result.
      Verify the only differences are the playbook's duplicate `.claude/CLAUDE.md` entry, which
      is harmless and out of scope, and `.editorconfig`, which the playbook gains by a manual
      edit outside this repository.

## 5. Support nested link targets and expose the list

- [ ] 5.1 Teach the installer to create a link target's parent directory when it does not exist,
      applied per manifest entry so any entry containing a slash works, routed through the same
      helper the rest of the script uses so dry-run still changes nothing. Verify against a
      sandbox home with no `.claude` directory that the directory is created as a real directory
      and the link lands inside it.
- [ ] 5.2 Verify the nested case is idempotent: run the installer twice against the same sandbox
      home and confirm the second run reports the entry unchanged and creates no backup.
- [ ] 5.3 Verify dry-run mode covers nested entries: run with `--dry-run` against a sandbox home
      with no `.claude` directory and confirm the directory is not created, the sandbox is left
      empty, and the plan names the link it would make.
- [ ] 5.4 Add a `--list` flag that prints each managed path on its own line and exits without
      touching the filesystem. Verify it leaves a sandbox home empty and that the entry
      containing a slash is printed whole rather than split.

## 6. Rework the bootstrap suite around the list

- [ ] 6.1 Change `tests/bootstrap.bats` to take its expected files from the installer's `--list`
      output rather than a hand-written copy, and drop the count from the test name. Verify the
      test asserts the list is non-empty before looping, so it cannot pass vacuously, and that
      adding or removing a manifest entry requires no edit to the test.
- [ ] 6.2 Add coverage for the nested entry: it resolves to the repository file, its parent in
      the sandbox home is a real directory rather than a link into the repository, and a second
      run leaves it unchanged with no backup. Verify with `bats tests/bootstrap.bats`.

## 7. Delete the checker configuration

- [ ] 7.1 Delete `.editorconfig-checker.json` and pass the equivalent flag wherever the checker
      runs — the CI formatting job and the README — each with a one-line note saying why the
      check is suppressed. Verify the checker reports the repository clean with the flag, and
      that without it the aligned continuation lines in `.gitaliases` are flagged, proving the
      flag is doing the same work the deleted file did.

## 8. Document both paths

- [ ] 8.1 Update the Setup section of `README.md` for the new installer path and the extended
      file list, replacing the hand-written `ln` commands with the current entries. Verify by
      following the README's manual instructions against a sandbox home and getting the same
      links the installer produces.
- [ ] 8.2 Add the missing `.gitignore` row to the Contents table, noting it is the global
      excludes file, and an `.editorconfig` row noting it configures both this repository and
      your other projects. Verify every linked entry in the manifest now appears in the table.
- [ ] 8.3 Add a short note to `README.md` explaining that these dotfiles are normally installed by
      the `mac-dev-setup` playbook, that the installer is the standalone route, and that both
      produce the same links. Verify a reader can tell from the README alone which route to use
      and that the two are equivalent.
