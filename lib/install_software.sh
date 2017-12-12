#!/bin/bash

install_nvm() {
    curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.7/install.sh | bash
}

install_software() {
    # shellcheck disable=SC2154
    if [[ "$(command -v nvm)" -ne "nvm" ]]; then
        install_nvm
    fi
}
