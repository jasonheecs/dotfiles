## ADDED Requirements

### Requirement: Workflow definitions are validated

The repository's continuous integration workflow definitions SHALL be validated automatically,
covering both the workflow structure and any shell embedded in its steps. Validation SHALL cover
every workflow file present, discovered rather than listed by hand, so that adding a workflow
brings it into scope. A validation finding SHALL fail verification.

#### Scenario: A workflow references an action that does not exist

- **WHEN** a workflow step references an action or a version that cannot be resolved
- **THEN** verification fails and names the step

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
