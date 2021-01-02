#!/bin/bash

install_homebrew() {
    # Check for Homebrew, install if we don't have it
    if test ! "$(which brew)"; then
        echo "Installing homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
    fi

    # # Update homebrew recipes
    brew update

    # Install GNU core utilities (those that come with OS X are outdated)
    brew install coreutils

    # Install GNU `find`, `locate`, `updatedb`, and `xargs`, g-prefixed
    brew install findutils

    PACKAGES=(
        ansible
        autoconf
        awscli
        ffmpeg
        gettext
        hadolint
        heroku/brew/heroku
        httpie
        imagemagick
        mariadb
        postgresql
        php
        pyenv
        rbenv
        ruby-build
        shellcheck
        sqlite
        thefuck
        tmux
        travis
        tree
        vim
        webpack
        wget
        zsh-autosuggestions
    )

    echo "Installing homebrew packages..."
    brew install "${PACKAGES[@]}"
    brew install --cask ngrok

    echo "Cleaning up for homebrew..."
    brew cleanup
}
