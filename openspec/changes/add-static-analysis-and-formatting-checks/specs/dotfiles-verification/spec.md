## ADDED Requirements

### Requirement: Formatting conventions are declared and enforced

The repository SHALL declare its whitespace and formatting conventions in a machine-readable
form that the editors in use can consume, and SHALL enforce those conventions automatically on
every tracked text file rather than by review. Enforcement SHALL NOT depend on any particular
editor honouring the declaration.

#### Scenario: A file is missing a final newline

- **WHEN** a tracked text file does not end with a newline
- **THEN** verification fails and names the file

#### Scenario: Indentation uses the wrong character

- **WHEN** a tracked file is indented with a character the declared conventions do not permit
  for that file
- **THEN** verification fails and names the file

#### Scenario: Trailing whitespace is introduced

- **WHEN** a line in a tracked file ends in whitespace
- **THEN** verification fails and names the file

#### Scenario: A newly added file is covered without being registered

- **WHEN** a new file is added and nothing is changed to declare it for formatting checks
- **THEN** the declared conventions apply to it automatically

#### Scenario: An editor without native support for the declaration

- **WHEN** a file is edited in an editor that does not read the declared conventions
- **THEN** that editor is configured to apply the same conventions by its own means, so the
  declaration and the editor do not disagree
- **AND** enforcement still catches a violation regardless of which editor produced it

#### Scenario: Conventions differ legitimately between file types

- **WHEN** two tracked file types conventionally use different indent widths
- **THEN** the declaration records the width per file type rather than forcing a single width
  across the repository

## MODIFIED Requirements

### Requirement: Static analysis is applied to shell scripts

Every shell script in the repository SHALL pass static analysis with no reported findings,
including the scripts that make up the verification suite itself. The set of analysed scripts
SHALL be discovered automatically rather than enumerated by hand, so that adding a script
brings it into scope without anyone remembering to register it. Analysis SHALL be applied only
to scripts written in a language the analyser understands. A finding MAY be suppressed only
where the suppression records why the reported pattern is intentional.

#### Scenario: A script introduces an unquoted expansion

- **WHEN** a lint-violating change is made to a shell script in the repository
- **THEN** verification fails and reports the finding

#### Scenario: A newly added script is covered without being registered

- **WHEN** a new shell script is added to the repository and nothing is changed to declare it
  for analysis
- **THEN** it is analysed anyway
- **AND** a lint violation inside it fails verification

#### Scenario: The verification suite's own scripts are analysed

- **WHEN** a lint-violating change is made to one of the repository's test files
- **THEN** verification fails and reports the finding, because those files are shell scripts
  and carry real logic

#### Scenario: A deliberate suppression records its reason

- **WHEN** a reported finding is suppressed because the flagged pattern is intentional
- **THEN** the reason is recorded alongside the suppression, so that a future reader can tell
  a considered exception from a forgotten one

#### Scenario: A suppression without a reason

- **WHEN** a finding is suppressed with no recorded reason
- **THEN** that is treated as an unresolved finding rather than an accepted one

#### Scenario: Analysis is not applied to a language it cannot read

- **WHEN** the repository contains configuration files written in zsh
- **THEN** the bash static analyser is not run against them, so that valid zsh is never
  reported as broken
- **AND** those files remain covered by the parse check appropriate to their language

### Requirement: Verification runs automatically on every change

The repository SHALL verify itself without manual action on every push and every proposed
change. Verification consists of three independent parts: the behavioural suite, which SHALL
run in a clean macOS environment that provisions its tooling from scratch; static analysis of
the repository's shell scripts; and enforcement of the repository's formatting conventions. A
change SHALL be reported as failing unless all three parts pass; no part alone is sufficient.

#### Scenario: A change is pushed

- **WHEN** a commit is pushed or a change is proposed
- **THEN** a clean macOS environment installs the required tooling and runs the full
  behavioural suite
- **AND** static analysis runs over the repository's shell scripts
- **AND** formatting conventions are enforced over the repository's tracked files
- **AND** all three report success

#### Scenario: Only one part fails

- **WHEN** the behavioural suite passes but static analysis reports a finding
- **THEN** the change is reported as failing verification

#### Scenario: The failing part is identifiable without reading logs

- **WHEN** verification fails
- **THEN** it is apparent from the reported result which of the three parts failed

#### Scenario: Tooling comes from a declared manifest

- **WHEN** an automated environment provisions itself
- **THEN** its tooling is installed from a manifest tracked in the repository, so that the
  same tooling can be installed locally with a single command
- **AND** both linters remain available through that manifest even though the parts of
  verification that use them provision themselves independently

#### Scenario: Running the behavioural suite locally is not a complete check

- **WHEN** a person runs the behavioural suite on their own machine and it passes
- **THEN** that result does not by itself establish that verification passes, because static
  analysis and formatting enforcement are separate parts
- **AND** the repository documents how to run those parts locally

#### Scenario: System-mutating scripts are never executed automatically

- **WHEN** the automated verification runs
- **THEN** the macOS system-defaults script is only syntax-checked and statically analysed,
  and is never executed, because running it would alter machine settings and force-quit
  running applications
