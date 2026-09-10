# Shared setup for the bats suite.

# Resolved from BASH_SOURCE, not $PWD, so it's correct regardless of the
# directory bats was invoked from.
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
export REPO_ROOT

# Persistent (gitignored) sandbox for the real-shell layer. .zshrc derives
# ZIM_HOME from ${ZDOTDIR:-${HOME}} and sources ~/.aliases from $HOME, so
# pointing both HOME and ZDOTDIR here gives full isolation with zero changes
# to any production dotfile.
ZDOT_SANDBOX="${REPO_ROOT}/tests/.cache/zdot"
export ZDOT_SANDBOX

# Idempotent: safe to call before every test. Symlinking (not copying) means
# edits to the real dotfiles are picked up immediately.
setup_zdot_sandbox() {
  mkdir -p "$ZDOT_SANDBOX"
  ln -sf "$REPO_ROOT/.zshrc" "$ZDOT_SANDBOX/.zshrc"
  ln -sf "$REPO_ROOT/.zimrc" "$ZDOT_SANDBOX/.zimrc"
  ln -sf "$REPO_ROOT/.aliases" "$ZDOT_SANDBOX/.aliases"
}

# Runs $* as a command in an interactive zsh confined to the sandbox. The
# cache persists across runs so zim's module install only pays its ~10s,
# network-dependent cost once, not on every test invocation.
sandboxed_zsh() {
  HOME="$ZDOT_SANDBOX" ZDOTDIR="$ZDOT_SANDBOX" zsh -i -c "$*"
}
