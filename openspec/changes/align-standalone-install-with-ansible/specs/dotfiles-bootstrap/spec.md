## ADDED Requirements

### Requirement: Standalone installation matches the provisioned result

This repository's dotfiles can be installed either by its own bootstrap or by the external
provisioning playbook that clones it. Both paths SHALL produce the same set of links in the home
directory. The bootstrap's manifest SHALL record that it mirrors the playbook's list and where
that list lives, so a reader can compare the two without first discovering that a second
installer exists.

#### Scenario: The same machine, either route

- **WHEN** a home directory is set up by the bootstrap alone, and another is set up by the
  external provisioning playbook alone
- **THEN** the same set of paths exists as links in both, resolving to the same repository files

#### Scenario: Installing over an already-provisioned machine

- **WHEN** the bootstrap runs on a machine the provisioning playbook has already set up
- **THEN** every link it manages is already correct
- **AND** it reports them as unchanged and creates no backups

#### Scenario: The manifest states what it mirrors

- **WHEN** a reader opens the bootstrap's manifest
- **THEN** it records that the list mirrors the external playbook's, and names where that list
  lives, so the list is not mistaken for a free-standing choice

#### Scenario: The two lists diverge

- **WHEN** the external playbook's list changes and this repository's manifest does not
- **THEN** the two install paths produce different home directories until the manifest is
  updated by hand, because nothing detects the divergence automatically

## MODIFIED Requirements

### Requirement: Managed dotfiles are linked into the home directory

The bootstrap process SHALL create a symbolic link in the user's home directory for every
dotfile it manages, with each link resolving to the corresponding file inside the
repository. A managed dotfile MAY live in a subdirectory of the repository, in which case the
link SHALL be created at the matching subdirectory of the home directory. Files the repository
deliberately does not install SHALL NOT be linked.

#### Scenario: Fresh machine with no existing dotfiles

- **WHEN** the bootstrap runs against a home directory containing none of the managed files
- **THEN** each managed dotfile exists in that home directory as a symbolic link whose
  target is the matching file in the repository
- **AND** the process exits with a success status

#### Scenario: A managed dotfile lives in a subdirectory

- **WHEN** a managed dotfile is tracked at a path below the repository root and the
  corresponding directory does not exist in the home directory
- **THEN** that directory is created
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

### Requirement: Every tracked dotfile is accounted for by the bootstrap

Each dotfile tracked anywhere in the repository SHALL be either installed by the bootstrap or
recorded as a deliberate exclusion. Adding a tracked dotfile without accounting for it SHALL
fail verification. This SHALL be checked automatically rather than by review, and the check
SHALL cover dotfiles in subdirectories as well as at the repository root.

#### Scenario: A new dotfile is added but not installed

- **WHEN** a new dotfile is tracked in the repository and is neither installed by the bootstrap
  nor listed as an exclusion
- **THEN** verification fails and names the unaccounted-for file

#### Scenario: A new dotfile is added in a subdirectory

- **WHEN** a new dotfile is tracked below the repository root and is neither installed nor
  excluded
- **THEN** verification fails and names it, rather than passing because the check only looked at
  the repository root

#### Scenario: A deliberately excluded file

- **WHEN** a tracked dotfile is recorded as a deliberate exclusion
- **THEN** verification passes without requiring it to be installed

#### Scenario: The exclusion list states a reason

- **WHEN** a file is recorded as a deliberate exclusion
- **THEN** the reason it is not installed is recorded alongside it, so that a future reader
  can tell an intentional omission from a forgotten one
