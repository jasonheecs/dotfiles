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

## MODIFIED Requirements

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

## REMOVED Requirements

### Requirement: Every tracked dotfile is accounted for by the bootstrap

**Reason**: The check required every tracked dotfile to be named in either the install list or a
parallel exclusion list, so adding or removing any dotfile meant editing bookkeeping that existed
only to satisfy the check. For a personal dotfiles repository the friction on routine change
outweighs the benefit, and the exclusion arrays had no other consumer.

**Migration**: The written reasons survive as a comment beside the manifest, which the
`Managed dotfiles are linked into the home directory` requirement now mandates. Completeness of
the manifest is no longer verified automatically; a dotfile that is added but never linked will
not be reported.
