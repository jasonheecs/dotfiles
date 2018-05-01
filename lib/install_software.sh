#!/bin/bash

# shellcheck source=./homebrew.sh
source "./homebrew.sh"
# shellcheck source=./ruby.sh
source "./ruby.sh"

install_nvm() {
    echo "Installing nvm..."
    curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.7/install.sh | bash
    nvm install node
}

install_software() {
    install_homebrew

    # shellcheck disable=SC2154
    if ! [[ -x "$(command -v nvm)" ]]; then
        # install_nvm
        install_nvm
    fi

    if ! [[ -x "$(command -v rbenv)" ]]; then
        # install_nvm
        install_ruby
    fi
}
