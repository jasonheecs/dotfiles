## ADDED Requirements

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

## MODIFIED Requirements

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
