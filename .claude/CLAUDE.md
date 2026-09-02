# Personal preferences

## Comments and documentation

Keep docstrings and comment blocks short (3-6 lines).
Comments explaining non-obvious behavior go next to the line they explain, not in a file-level header.
Comments terser than feels natural.

## Code structure

Prefer code that reads without comments. Extract named helpers once a function
does more than ~5 things in sequence. Group 4+ related parameters into a
dataclass or dict.

## Python code style

Return types on every signature. No roadmap phase numbers in code.

## Dependencies

Prefer a well-tested library over hand-rolling. Adding a dependency beats
writing your own parser; less code to own is the goal.

## Git commits and pull requests

No "Co-Authored-By: Claude" trailer, no "Generated with Claude Code" footer.
