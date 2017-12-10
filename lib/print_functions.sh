#!/bin/bash

print_result() {
    if [[ "$1" -eq 0 ]]; then
        print_success "$2"
    else
        print_error "$2"
    fi

    [[ "$3" == "true" ]] && [[ "$1" -ne 0 ]] \
        && exit
}

# Print output in green
print_success() {
    printf "\e[0;32m  [✔] %s\e[0m\n" "$1"
}

# Print output in red
print_error() {
    printf "\e[0;31m  [✖] %s %s\e[0m\n" "$1" "$2"
}

# Print output in yellow
print_question() {
    printf "\e[0;33m  [?] %s\e[0m" "$1"
}
