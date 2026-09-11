.PHONY: check test lint-shell lint-format lint-workflow

check: lint-shell lint-format lint-workflow test

test:
	bats tests/

lint-shell:
	shellcheck .osx install.sh tests/helpers/common.bash tests/*.bats
	tests/lint-gitaliases.sh

lint-format:
	editorconfig-checker

lint-workflow:
	actionlint
