#!/bin/bash

install_homebrew() {
    # Check for Homebrew, install if we don't have it
    if test ! "$(which brew)"; then
        echo "Installing homebrew..."
        ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    fi

    # Update homebrew recipes
    brew update

    # Install GNU core utilities (those that come with OS X are outdated)
    brew tap homebrew/dupes
    brew install coreutils
    brew install gnu-sed --with-default-names
    brew install gnu-tar --with-default-names
    brew install gnu-indent --with-default-names
    brew install gnu-which --with-default-names
    brew install gnu-grep --with-default-names

    # Install GNU `find`, `locate`, `updatedb`, and `xargs`, g-prefixed
    brew install findutils

    PACKAGES=(
        ansible
        autoconf
        awscli
        ffmpeg
        gettext
        git-crypt
        httpie
        imagemagick
        mariadb
        postgresql
        php
        python
        python3
        rbenv
        shellcheck
        sqlite
        thefuck
        tmux
        tree
        vim
        wget
        yarn
        zsh-autosuggestions
    )

    echo "Installing homebrew packages..."
    brew install "${PACKAGES[@]}"

    echo "Cleaning up for homebrew..."
    brew cleanup
}
