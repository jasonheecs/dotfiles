## Why

A linter is a program that reads code and points out likely mistakes without running it. This
repository has one — ShellCheck — and it currently reads a single file.

**Problem one: the linter almost never runs.**

ShellCheck is installed. It is wired into the test suite. It looks at `.osx` and stops. It does
not look at `tests/install.sh`, which is the script a brand-new machine runs to move files around
inside your home directory. It does not look at the five `.bats` files, which are the tests
themselves — those are shell scripts too, with real logic in them.

Why so little? Because the files are listed by hand. Someone wrote one test block that says
"check `.osx`", and that is the whole list. Add a script tomorrow and nobody checks it, because
nobody remembers to add another block. The written rules for this repository already say every
bash script gets checked. One test block is the entire reality behind that sentence.

**Problem two: four files are missing their last newline.**

Text files are supposed to end with a newline character. `.gitconfig`, `.gitaliases`,
`.tmux.conf`, and `.osx` all just stop mid-line instead.

That sounds cosmetic. It is not, for two of them. `.gitconfig` and `.gitaliases` are files you
add lines to. Right now `.gitconfig` ends on the line `path = ~/.gitcredentials`, with no newline
after it. Add another line and it does not go on a new line — it gets glued onto the end of that
one, and the setting breaks.

**Problem three: nothing writes down the formatting rules.**

These files get edited from vim, VS Code, and JetBrains. Each one has its own idea of what the
Tab key should do. Nothing tells them what this repository wants.

Vim in particular is set up to insert a real tab character, because `.vimrc` turns on
`autoindent` but never turns on `expandtab`. There is not a single tab anywhere in this
repository, so that is a loaded gun that has not gone off yet. And `.zshrc` already argues with
itself: one function is indented four spaces while the `case` block below it uses two.

None of this gets caught by reading the code, because none of it is visible when you read the
code.

See the [CI shape diagram](design.md#ci-shape) for how the new checks fit together.

## What Changes

- Add a `shellcheck` job that finds every shell script by itself and checks all of them, instead
  of working from a hand-written list. The `.bats` test files get checked for the first time.
- Delete the one `.osx passes shellcheck` test from `tests/syntax.bats`. The new job covers
  `.osx`, and having two different things check the same file is how they end up disagreeing.
  `tests/syntax.bats` goes back to doing only what its name says: checking that files parse.
- Tell ShellCheck to stop complaining about three lines in `tests/shell.bats`, and write down
  why. It flags the single quotes in `sandboxed_zsh 'echo $PNPM_HOME'` as a probable typo. They
  are not. That text has to arrive at the test's sandboxed shell *unexpanded*, so that shell is
  the one that fills in the variable. Switching to double quotes would fill it in too early, from
  the wrong shell, and the test would compare two wrong values and pass.
- Add a `.editorconfig` file. This is a small standard file that says "spaces not tabs, end files
  with a newline, no trailing spaces" in a format all three editors can read.
- Add an `editorconfig-checker` job so those rules are actually enforced on every file, whether
  or not a given editor bothered to read them.
- Add the missing final newline to the four files.
- Write the indentation rules into `.vimrc` directly. Vim is the only one of the three editors
  that cannot read `.editorconfig` without a plugin, and `.vimrc` does not load plugins at all.
- Fix the mixed indentation inside `.zshrc`.
- **BREAKING**, for how you work locally: `bats tests/` stops meaning "everything passed". The
  new checks live in their own CI jobs, so a clean test run and a green CI run are no longer the
  same thing.

## Capabilities

### New Capabilities

None. Nothing new gets built here. Existing promises start being kept, and one new kind of check
joins a set that already exists.

### Modified Capabilities

- `dotfiles-verification`: two rules change and one is added.
  - *Static analysis is applied to shell scripts* (modified) — today one file, named by hand.
    Becomes: every shell script, found automatically. If a warning gets switched off, the reason
    has to be written next to it, so a later reader can tell a deliberate choice from a
    forgotten one.
  - *Verification runs automatically on every change* (modified) — today this describes one
    macOS machine running everything. Checking now happens in three separate places, so the rule
    has to describe all three and say that passing one is not enough.
  - *Formatting conventions are declared and enforced* (added) — there is no rule about
    whitespace at all right now, which is exactly why four files drifted and nobody noticed.

## Impact

- `.github/workflows/ci.yml` — gains two jobs.
- `tests/syntax.bats` — loses the `.osx passes shellcheck` test.
- `tests/shell.bats` — gains three comments switching off a warning, each with its reason.
- `.editorconfig` — new file.
- `.gitconfig`, `.gitaliases`, `.tmux.conf`, `.osx` — gain a final newline.
- `.vimrc` — gains indentation settings.
- `.zshrc` — indentation made consistent.
- `README.md` — the Testing section currently implies `bats tests/` is the whole story. It has to
  say there are three parts now, and how to run each one.
- `tests/Brewfile` — keeps `shellcheck`, gains `editorconfig-checker`, so both are still one
  command to install locally.
- Four of the edited files are dotfiles that get linked into your home directory. Every edit to
  them is whitespace or an added setting. Nothing they configure behaves differently.
