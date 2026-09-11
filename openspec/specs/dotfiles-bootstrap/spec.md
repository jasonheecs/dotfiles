# dotfiles-bootstrap Specification

## Purpose
Installing this repository's configuration files onto a machine, so that a fresh setup is a
single repeatable command rather than a list of instructions a person copies by hand and can
silently get wrong, whether that machine is provisioned by the external playbook or set up from
a standalone clone.

## Requirements

### Requirement: Managed dotfiles are linked into the home directory

The bootstrap process SHALL create a symbolic link in the user's home directory for every
dotfile it manages, with each link resolving to the corresponding file inside the
repository. A managed dotfile MAY live in a subdirectory of the repository, in which case the
link SHALL be created at the matching subdirectory of the home directory. Files the repository
deliberately does not install SHALL NOT be linked, and the reason SHALL be recorded alongside
the manifest so a future reader can tell an intentional omission from a forgotten one.

#### Scenario: Fresh machine with no existing dotfiles

- **WHEN** the bootstrap runs against a home directory containing none of the managed files
- **THEN** each managed dotfile exists in that home directory as a symbolic link whose
  target is the matching file in the repository
- **AND** the process exits with a success status

#### Scenario: A managed dotfile lives in a subdirectory

- **WHEN** a managed dotfile is tracked at a path below the repository root and the
  corresponding directory does not exist in the home directory
- **THEN** that directory is created as a real directory
- **AND** the link is created inside it, resolving to the repository file

#### Scenario: Files excluded from installation

- **WHEN** the bootstrap runs
- **THEN** the continuous integration workflow is NOT linked into the home directory, because it
  configures this repository and has no meaning outside it

#### Scenario: The macOS defaults script is linked but never run

- **WHEN** the bootstrap runs
- **THEN** the macOS system-defaults script is linked into the home directory like any other
  managed dotfile
- **AND** it is not executed, because linking a script and running it are different acts

#### Scenario: The global git excludes file is installed

- **WHEN** the bootstrap runs
- **THEN** the repository's `.gitignore` is linked into the home directory, because the
  repository's git configuration names it as the global excludes file and git treats a missing
  excludes file as an empty one rather than reporting an error

#### Scenario: The formatting declaration is installed

- **WHEN** the bootstrap runs
- **THEN** the repository's formatting declaration is linked into the home directory, where it
  serves as the user's default for projects that do not declare their own
- **AND** it continues to govern this repository, because the repository's own copy is found
  first and declares itself the stopping point of the search

#### Scenario: The formatting declaration does not force spaces on tab-indented formats

- **WHEN** the formatting declaration is in use as the home-directory default
- **THEN** formats whose conventions require tab indentation are declared as tab-indented, so
  that serving as a global default cannot corrupt them

### Requirement: Standalone installation matches the provisioned result

This repository's dotfiles can be installed either by its own bootstrap or by the external
provisioning playbook that clones it. Both paths SHALL produce the same set of links in the home
directory.

#### Scenario: The same machine, either route

- **WHEN** a home directory is set up by the bootstrap alone, and another is set up by the
  external provisioning playbook alone
- **THEN** the same set of paths exists as links in both, resolving to the same repository files

#### Scenario: Installing over an already-provisioned machine

- **WHEN** the bootstrap runs on a machine the provisioning playbook has already set up
- **THEN** every link it manages is already correct
- **AND** it reports them as unchanged and creates no backups

#### Scenario: The two lists diverge

- **WHEN** the external playbook's list changes and this repository's manifest does not
- **THEN** the two install paths produce different home directories until the manifest is
  updated by hand, because nothing detects the divergence automatically

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

### Requirement: The managed file list is readable without parsing the bootstrap

The bootstrap SHALL be able to report the paths it manages, one per line, without installing
anything. Verification SHALL obtain the list this way rather than by reading the bootstrap's
source text, so that a manifest entry's form — including one naming a path in a subdirectory —
cannot cause the list to be misread.

#### Scenario: Listing the managed paths

- **WHEN** the bootstrap is asked to report its managed paths
- **THEN** it prints each managed path on its own line and makes no change to the home directory

#### Scenario: A manifest entry naming a subdirectory

- **WHEN** the manifest contains an entry whose path includes a directory separator
- **THEN** that entry is reported whole, rather than split into fragments

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
