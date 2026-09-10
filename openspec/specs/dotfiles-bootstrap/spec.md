# dotfiles-bootstrap Specification

## Purpose
Installing this repository's configuration files onto a machine, so that a fresh setup is a
single repeatable command rather than a list of instructions a person copies by hand and can
silently get wrong, and proving that the installer actually covers every file the repository
tracks.

## Requirements

### Requirement: Managed dotfiles are linked into the home directory

The bootstrap process SHALL create a symbolic link in the user's home directory for every
dotfile it manages, with each link resolving to the corresponding file inside the
repository. Files the repository deliberately does not install SHALL NOT be linked.

#### Scenario: Fresh machine with no existing dotfiles

- **WHEN** the bootstrap runs against a home directory containing none of the managed files
- **THEN** each managed dotfile exists in that home directory as a symbolic link whose
  target is the matching file in the repository
- **AND** the process exits with a success status

#### Scenario: Files excluded from installation

- **WHEN** the bootstrap runs
- **THEN** the macOS system-defaults script and the repository's own `.gitignore` are NOT
  linked into the home directory, because one is executed on demand and the other applies
  only to the repository itself

### Requirement: Bootstrap is idempotent

Running the bootstrap more than once SHALL be safe. A second run SHALL make no further
changes and SHALL report success.

#### Scenario: Running twice in a row

- **WHEN** the bootstrap has already completed successfully and is run again unchanged
- **THEN** every link points where it did before
- **AND** no backup files are created by the second run
- **AND** the process exits with a success status

### Requirement: Pre-existing user files are never destroyed

The bootstrap SHALL NOT overwrite a real file that already exists at a link target. It
SHALL preserve that file's contents at a discoverable location before creating the link.
An existing link that already points at the correct repository file SHALL be left untouched.

#### Scenario: A real file occupies the target path

- **WHEN** a regular file already exists at the path where a managed dotfile would be linked
- **THEN** the original file's contents are preserved under a clearly related backup name
- **AND** the managed dotfile is then linked into place
- **AND** the user is told that a backup was made

#### Scenario: A correct link already exists

- **WHEN** the target path is already a symbolic link resolving to the correct repository file
- **THEN** the bootstrap leaves it as-is and creates no backup

#### Scenario: A link points somewhere unexpected

- **WHEN** the target path is a symbolic link resolving to something other than the correct
  repository file
- **THEN** the bootstrap replaces it with the correct link
- **AND** reports that it did so

### Requirement: Changes can be previewed without being applied

The bootstrap SHALL offer a mode that reports exactly what it would do while making no
change to the filesystem.

#### Scenario: Previewing on a machine that has never been set up

- **WHEN** the bootstrap is invoked in preview mode
- **THEN** it lists each link it would create and each backup it would take
- **AND** the home directory is byte-for-byte unchanged afterwards
- **AND** the process exits with a success status

### Requirement: Installation target follows the invoking environment

The bootstrap SHALL install into the home directory of the environment invoking it, and
SHALL NOT contain any hard-coded absolute user path. It SHALL locate the repository from
its own location rather than from the current working directory.

#### Scenario: Installing into an alternate home directory

- **WHEN** the bootstrap is invoked with the home directory pointing at an arbitrary empty
  directory
- **THEN** all links are created inside that directory
- **AND** the real home directory of the machine is left untouched

#### Scenario: Invoked from an unrelated working directory

- **WHEN** the bootstrap is invoked by absolute path from a working directory outside the
  repository
- **THEN** the links it creates still resolve to files inside the repository
- **AND** the process exits with a success status

### Requirement: Every tracked dotfile is accounted for by the bootstrap

Each dotfile tracked at the repository root SHALL be either installed by the bootstrap or
recorded as a deliberate exclusion. Adding a tracked dotfile without accounting for it SHALL
fail verification. This SHALL be checked automatically rather than by review.

#### Scenario: A new dotfile is added but not installed

- **WHEN** a new dotfile is tracked at the repository root and is neither installed by the
  bootstrap nor listed as an exclusion
- **THEN** verification fails and names the unaccounted-for file

#### Scenario: A deliberately excluded file

- **WHEN** a tracked dotfile is recorded as a deliberate exclusion
- **THEN** verification passes without requiring it to be installed

#### Scenario: The exclusion list states a reason

- **WHEN** a file is recorded as a deliberate exclusion
- **THEN** the reason it is not installed is recorded alongside it, so that a future reader
  can tell an intentional omission from a forgotten one

### Requirement: Installed setup produces a working shell

The repository SHALL verify automatically that running the bootstrap on a clean macOS
environment yields a shell that starts successfully.

#### Scenario: Fresh machine end to end

- **WHEN** a clean macOS environment checks out the repository, installs the required
  tooling, and runs the bootstrap against its home directory
- **THEN** an interactive shell started afterwards exits successfully

#### Scenario: System-mutating scripts stay untouched

- **WHEN** the bootstrap runs, in any environment
- **THEN** it never executes the macOS system-defaults script, because that script alters
  machine settings and force-quits running applications
