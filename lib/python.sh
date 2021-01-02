#!/bin/bash

install_python() {
	LATEST_PYTHON_VERSION="$(pyenv install --list | grep -v - | grep -v b | tail -1 | tr -d '[:space:]')"
	pyenv install "${LATEST_PYTHON_VERSION}"
	pyenv global "${LATEST_PYTHON_VERSION}"
}
