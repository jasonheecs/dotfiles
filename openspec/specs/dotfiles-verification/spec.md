## Purpose

Automatically checking that these configuration files are correct before they reach a real
shell, so that a broken config is caught by a test run instead of by every terminal window
the user opens afterwards.

## Requirements

### Requirement: Configuration files are checked for syntax errors

The verification suite SHALL confirm that every shell configuration file in the repository
parses without error, using a checker appropriate to that file's actual shell language. A
parse failure in any file SHALL fail the suite.

#### Scenario: A zsh configuration file contains a syntax error

- **WHEN** an unbalanced construct is introduced into a zsh startup file
- **THEN** the suite fails and names the offending file

#### Scenario: A bash script contains a syntax error

- **WHEN** an unbalanced construct is introduced into a bash script in the repository
- **THEN** the suite fails and names the offending file

#### Scenario: Checkers are matched to the correct language

- **WHEN** the suite checks a zsh file
- **THEN** it does not report failures caused by applying bash-only rules to zsh syntax,
  so that valid zsh is never reported as broken

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

### Requirement: Workflow definitions are validated

The repository's continuous integration workflow definitions SHALL be validated automatically,
covering both the workflow structure and any shell embedded in its steps. Validation SHALL cover
every workflow file present, discovered rather than listed by hand, so that adding a workflow
brings it into scope. A validation finding SHALL fail verification.

#### Scenario: A workflow step sets an input an action does not define

- **WHEN** a workflow step sets a `with:` input that is not defined by the action it references
- **THEN** verification fails and names the step

Note: validation of action references is limited to what the validator can check offline. It
does not confirm that a referenced action or version actually exists on GitHub — only that
`with:` inputs match the action's known schema, for actions it has metadata for.

#### Scenario: A workflow expression is malformed

- **WHEN** a workflow contains an expression that is not valid for the context it appears in
- **THEN** verification fails and reports the finding

#### Scenario: Shell inside a step has a lint violation

- **WHEN** a lint-violating command is written into a workflow step's shell block
- **THEN** verification fails and reports the finding against that step, because shell inside a
  workflow is subject to the same analysis as shell in a script file

#### Scenario: A newly added workflow is covered without being registered

- **WHEN** a new workflow file is added and nothing is changed to declare it for validation
- **THEN** it is validated anyway

#### Scenario: The validator runs inside the workflow it validates

- **WHEN** a workflow is broken badly enough that the automation cannot parse it
- **THEN** the failure surfaces as the automation declining to run rather than as a validation
  finding, and this limitation is recorded so that a green result is not mistaken for proof the
  workflow file is well-formed in every respect

#### Scenario: Validation is available locally

- **WHEN** a person wants to check a workflow change before pushing it
- **THEN** the validator is installable from the repository's tooling manifest with the same
  single command as the other checks

### Requirement: Each tool accepts its own configuration

The verification suite SHALL confirm that each configured tool loads its configuration
successfully. Loading a configuration for verification SHALL NOT disturb any instance of
that tool the user is currently running.

#### Scenario: Git configuration is well-formed

- **WHEN** the suite reads the repository's git configuration and alias files
- **THEN** both parse successfully

#### Scenario: A git alias resolves end to end

- **WHEN** a git alias that depends on a custom output format is invoked in a throwaway
  repository
- **THEN** it completes successfully, proving the alias and the format definition it relies
  on are still present together

#### Scenario: The editor loads its configuration

- **WHEN** the editor is started non-interactively with the repository's configuration and
  told to quit immediately
- **THEN** it exits successfully with no error output

#### Scenario: The terminal multiplexer loads its configuration

- **WHEN** the suite loads the multiplexer configuration in an isolated instance
- **THEN** the configuration is accepted with no error output
- **AND** any multiplexer session the user already had running is unaffected
- **AND** the isolated instance is shut down when the check finishes

### Requirement: Shell startup behavior is verified in isolation

The verification suite SHALL start a real interactive shell using the repository's
configuration and assert on the resulting environment. This SHALL happen in an isolated
environment, and SHALL NOT read from or write to the user's own shell state.

#### Scenario: The user's environment is not disturbed

- **WHEN** the shell startup checks run
- **THEN** no file in the user's real home directory is created, modified, or deleted

#### Scenario: Startup succeeds cleanly

- **WHEN** an interactive shell is started with the repository configuration and told to
  exit immediately
- **THEN** it exits successfully and produces no error output

#### Scenario: A path entry is not duplicated on repeated startup

- **WHEN** the shell configuration is loaded more than once in the same session
- **THEN** the package manager's binary directory appears in the executable search path
  exactly once

#### Scenario: Optional version managers are absent

- **WHEN** an interactive shell is started in an environment where the optional Ruby and
  Node version managers are not installed
- **THEN** startup still succeeds with no error output

#### Scenario: Shell aliases are available

- **WHEN** an interactive shell finishes starting up
- **THEN** the aliases defined by the repository are defined in that shell

#### Scenario: Expected environment variables are set

- **WHEN** an interactive shell finishes starting up
- **THEN** the package-manager and Homebrew-related environment variables the configuration
  sets hold their configured values

### Requirement: Verification runs automatically on every change

The repository SHALL verify itself without manual action on every push and every proposed
change. Verification consists of four independent parts: the behavioural suite, which SHALL
run in a clean macOS environment that provisions its tooling from scratch because it exercises
the shell the dotfiles target; static analysis of the repository's shell scripts; enforcement
of the repository's formatting conventions; and validation of its workflow definitions. Only
the behavioural suite is tied to a platform; the other parts MAY run in any environment. A
change SHALL be reported as failing unless all four parts pass; no part alone is sufficient.

#### Scenario: A change is pushed

- **WHEN** a commit is pushed or a change is proposed
- **THEN** a clean macOS environment installs the required tooling and runs the full
  behavioural suite
- **AND** static analysis runs over the repository's shell scripts
- **AND** formatting conventions are enforced over the repository's tracked files
- **AND** the repository's workflow definitions are validated
- **AND** all four report success

#### Scenario: Only one part fails

- **WHEN** the behavioural suite passes but static analysis reports a finding
- **THEN** the change is reported as failing verification

#### Scenario: The failing part is identifiable without reading logs

- **WHEN** verification fails
- **THEN** it is apparent from the reported result which of the four parts failed

#### Scenario: Tooling comes from a declared manifest

- **WHEN** an automated environment provisions itself
- **THEN** its tooling is installed from a manifest tracked in the repository, so that the
  same tooling can be installed locally with a single command
- **AND** every linter remains available through that manifest even though the parts of
  verification that use them provision themselves independently

#### Scenario: Running the behavioural suite locally is not a complete check

- **WHEN** a person runs the behavioural suite on their own machine and it passes
- **THEN** that result does not by itself establish that verification passes, because static
  analysis, formatting enforcement, and workflow validation are separate parts
- **AND** the repository documents how to run those parts locally

#### Scenario: System-mutating scripts are never executed automatically

- **WHEN** the automated verification runs
- **THEN** the macOS system-defaults script is only syntax-checked and statically analysed,
  and is never executed, because running it would alter machine settings and force-quit
  running applications

### Requirement: Machine-dependent checks do not cause false failures

Checks whose outcome depends on optional software being installed on the machine SHALL be
skipped rather than failed when that software is legitimately absent.

#### Scenario: An alias targets software not present in the automated environment

- **WHEN** the suite verifies that each shell alias points at an available command, and the
  automated environment does not have that optional software installed
- **THEN** the check is reported as skipped rather than failed

#### Scenario: The same check on a developer machine

- **WHEN** the same check runs on a machine where the software is expected
- **THEN** an alias pointing at a command that cannot be found fails the suite
