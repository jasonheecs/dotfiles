#!/bin/bash

install_ruby() {
    LATEST_RUBY_VERSION="$(rbenv install -l | grep -v - | tail -1 | tr -d '[:space:]')"
    rbenv install "${LATEST_RUBY_VERSION}"
    rbenv global "${LATEST_RUBY_VERSION}"
    rbenv rehash
}
