# Personal preferences

## Comments and documentation

- Keep docstrings and comment blocks short and terse (3-6 lines).
- Comments explaining non-obvious behavior go next to the line they explain, not in a file-level header.
- Comments terser than feels natural.

## Code structure

- Prefer code that reads without comments
- Extract named helpers once a function does more than ~5 things in sequence.
- Group 4+ related parameters into a dataclass or dict.

## Code quality

- Extract a helper on code duplication.
- Functions and modules should follow SRP and be self documenting. Extract
  out concerns if necessary.
- A function that needs section comments wants splitting instead.
- Test through the public surface; a private helper is fair game only when
  it's pure and dodges a heavy dependency in tests.

## Python code style

- Return types on every signature

## Dependencies

- Prefer a well-tested library over hand-rolling.
- Adding a dependency beats writing your own parser; less code to own is the goal.

## Git commits and pull requests

- No "Co-Authored-By: Claude" trailer, no "Generated with Claude Code" footer
