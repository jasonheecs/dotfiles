#!/bin/bash

ask_for_confirmation() {
    print_question "$1 (y/n) "
    read -nr 1
    printf "\n"
}

answer_is_yes() {
    [[ "$REPLY" =~ ^[Yy]$ ]] \
    && return 0 \
    || return 1
}
