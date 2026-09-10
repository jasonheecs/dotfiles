# Shared setup for the bats suite.

# Resolved from BASH_SOURCE, not $PWD, so it's correct regardless of the
# directory bats was invoked from.
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
export REPO_ROOT
