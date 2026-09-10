## Purpose

Automatically checking that these configuration files are correct before they reach a real
shell, so that a broken config is caught by a test run instead of by every terminal window
the user opens afterwards.

## ADDED Requirements

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

Every bash script in the repository SHALL pass static analysis with no reported findings.

#### Scenario: A script introduces an unquoted expansion

- **WHEN** a lint-violating change is made to a bash script
- **THEN** the suite fails and reports the finding

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

The repository SHALL run its full verification suite without manual action on every push
and every proposed change, in a clean macOS environment that provisions its tooling from
scratch.

#### Scenario: A change is pushed

- **WHEN** a commit is pushed or a change is proposed
- **THEN** a clean macOS environment installs the required tooling and runs the full
  verification suite
- **AND** the suite passes

#### Scenario: Tooling comes from a declared manifest

- **WHEN** the automated environment provisions itself
- **THEN** the test tooling is installed from a manifest tracked in the repository, so that
  the same tooling can be installed locally with a single command

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
