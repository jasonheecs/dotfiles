## ADDED Requirements

### Requirement: Verification can be run locally with one command

The repository SHALL provide a single command that runs every part of its verification, so that
a person can establish locally what the automation would conclude. Each part SHALL also be
runnable on its own. The commands the automation runs and the commands a person runs SHALL come
from the same definitions, so the two cannot drift apart. The available commands SHALL be
discoverable without reading the file that defines them.

#### Scenario: Checking everything before pushing

- **WHEN** a person runs the aggregate command on a clean checkout with the tooling installed
- **THEN** every part of verification runs
- **AND** the result matches what the automation would report for the same state

#### Scenario: Running one part while iterating

- **WHEN** a person is fixing findings from one particular check
- **THEN** that check can be run on its own, without running the others

#### Scenario: The automation and the person run the same thing

- **WHEN** a check's command changes
- **THEN** it changes in one place, and both the automation and the local command pick up the
  change, because neither holds its own copy

#### Scenario: A part fails

- **WHEN** one part of verification fails during the aggregate command
- **THEN** the output identifies which part failed

#### Scenario: A new check is added

- **WHEN** a new check is added to the repository's verification
- **THEN** it is reachable from the aggregate command, so that command does not silently fall
  behind what the automation runs

#### Scenario: Finding out what can be run

- **WHEN** a person wants to know which commands are available
- **THEN** a command lists them with a short description of each
