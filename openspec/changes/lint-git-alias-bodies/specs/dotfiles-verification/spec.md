## ADDED Requirements

### Requirement: Shell embedded in configuration is analysed

Shell code that lives inside a configuration file's values, rather than in a file of its own,
SHALL be subject to the same static analysis as the repository's shell scripts. The code
analysed SHALL be the code the tool actually executes, obtained by asking that tool to resolve
its own configuration, rather than text extracted from the file by pattern matching. Analysis
SHALL reproduce the way the tool invokes the code, including any arguments the tool supplies, so
that the analyser does not report findings that are artefacts of examining a fragment in
isolation. The set of embedded scripts analysed SHALL be discovered from the configuration
rather than listed by hand.

#### Scenario: An embedded script has an unquoted expansion

- **WHEN** a git alias body passes an argument to a command without quoting it
- **THEN** verification fails and reports the finding against that alias

#### Scenario: The analysed code is what the tool runs, not what the file shows

- **WHEN** an alias body is written with quoting that the configuration format discards before
  the shell sees it
- **THEN** analysis operates on the version the tool resolved, so the discarded quoting is
  reported as missing rather than assumed present

#### Scenario: A newly added alias is covered without being registered

- **WHEN** a new alias containing shell is added to the configuration and nothing is changed to
  declare it for analysis
- **THEN** it is analysed anyway

#### Scenario: The tool's own argument handling is accounted for

- **WHEN** an embedded script relies on arguments the tool appends when it invokes the script
- **THEN** analysis supplies them the same way, so the script is not reported as ignoring
  arguments that it does in fact receive

#### Scenario: An embedded script spans multiple lines

- **WHEN** a resolved alias body contains newlines
- **THEN** it is analysed as one script, rather than being altered or split in a way that
  produces findings the real code would not

#### Scenario: The analysed dialect matches the interpreter

- **WHEN** an embedded script is analysed
- **THEN** the dialect checked is the one the tool actually invokes it with, so that constructs
  which would fail under that interpreter are reported rather than excused

### Requirement: Every git alias is exercised end to end

Each git alias the repository defines SHALL be invoked against a throwaway repository and
asserted on, so that an alias which parses and lints but does not work is still caught. An alias
that takes arguments SHALL be exercised with arguments, including one containing a space, because
argument handling is where both the configuration format's quoting and the shell's word splitting
can silently corrupt a value. Adding an alias without exercising it SHALL fail verification.

#### Scenario: An alias is defined but never invoked

- **WHEN** an alias is defined in the repository's git configuration and no test invokes it
- **THEN** verification fails and names the unexercised alias

#### Scenario: An alias that depends on a custom output format

- **WHEN** an alias relying on a custom pretty format is invoked in a throwaway repository
- **THEN** it completes successfully, proving the alias and the format definition it relies on
  are still present together

#### Scenario: An argument containing a space

- **WHEN** an argument-taking alias is invoked with an argument containing a space
- **THEN** the alias receives it as a single value and acts on it as one, rather than splitting
  it into several

#### Scenario: An alias with a defaulted argument

- **WHEN** an alias that defaults an omitted argument is invoked without that argument
- **THEN** it behaves as though the default had been supplied

#### Scenario: An alias that searches history

- **WHEN** an alias that searches commits is invoked in a throwaway repository containing a
  commit it should match
- **THEN** that commit appears in its output

#### Scenario: A destructive alias

- **WHEN** an alias that rewrites branches or history is exercised
- **THEN** it is run against a throwaway repository prepared with the references it expects, and
  its effect on those references is asserted, rather than the alias being verified by reading it

#### Scenario: The user's own repositories are untouched

- **WHEN** the alias tests run
- **THEN** every invocation happens inside a temporary repository created for the test and
  removed afterwards, and no repository the user owns is read from or written to
