.PHONY: help check test lint-shell lint-format lint-workflow
.DEFAULT_GOAL := help

help: ## List available targets
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  %-14s %s\n", $$1, $$2}'

check: lint-shell lint-format lint-workflow test ## Run every check

test: ## Run the bats behavioural suite
	bats tests/

lint-shell: ## Run ShellCheck over scripts and git alias bodies
	shellcheck .osx install.sh tests/helpers/common.bash tests/*.bats
	tests/lint-gitaliases.sh

lint-format: ## Check formatting against .editorconfig
	editorconfig-checker

lint-workflow: ## Validate GitHub Actions workflows
	actionlint
