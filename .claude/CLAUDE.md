# Personal preferences

## Comments and documentation

Keep module docstrings and comment blocks short: state what the module is
and the one non-obvious constraint, then stop (usually 3-6 lines).
A comment that explains genuinely non-obvious behavior belongs
next to the specific line it explains, not in a file-level header.

## Code structure

Prefer code that reads without comments. When a function does more than
~5 distinct things in sequence, extract each into a named helper so the
caller reads as an outline. When a function or constructor signature takes
4 or more related parameters, group them into a dataclass or dict instead
of a flat parameter list.

## Git commits and pull requests

Don't add a "Co-Authored-By: Claude" trailer to commit messages.
Don't add a "Generated with Claude Code" footer to pull request descriptions.
