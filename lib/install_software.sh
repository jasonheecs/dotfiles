#!/bin/bash

install_nvm() {
    curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.7/install.sh | bash
}

install_software() {
    echo 'in'
    # shellcheck disable=SC2154
    if ! [[ -x "$(command -v nvm)" ]]; then
        # install_nvm
        install_nvm
    fi
}
