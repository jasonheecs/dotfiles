#!/bin/bash


# Get the dotfiles directory's absolute path
SCRIPT_DIR="$(cd "$(dirname "$0")" || exit; pwd -P)"
DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"

dir_backup=~/.dotfiles_old             # old dotfiles backup directory

# Get current dir (so run this script from anywhere)
export DOTFILES_DIR
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# include dependencies
# shellcheck source=./lib/print_functions.sh
source "${DOTFILES_DIR}/lib/print_functions.sh"
# shellcheck source=./lib/print_functions.sh
source "${DOTFILES_DIR}/lib/user_input.sh"

# Create dotfiles_old in homedir
echo -n "Creating $dir_backup for backup of any existing dotfiles in ~..."
mkdir -p $dir_backup
echo "done"

# Change to the dotfiles directory
echo -n "Changing to the ${DOTFILES_DIR} directory..."
cd "${DOTFILES_DIR}" || exit
echo "done"

##
# Util Functions
##
execute() {
  $1 &> /dev/null
  print_result $? "${2:-$1}"
}

##
# Symlink files
##

declare -a FILES_TO_SYMLINK=(
    'shell/aliases'
    'shell/zshrc' 

    'git/gitaliases'
    'git/gitconfig'
    'git/gitignore'
)

for i in "${FILES_TO_SYMLINK[@]}"; do
    if [[ -f ~/.${i##*/} ]]; then
        echo "Moving existing ~/.${i##*/} dotfiles from ~ to $dir_backup"
        mv ~/."${i##*/}" ${dir_backup}/
    fi
done

main() {
    local i=''
    local sourceFile=''
    local targetFile=''

    for i in "${FILES_TO_SYMLINK[@]}"; do
        sourceFile="$(pwd)/$i"
        targetFile="$HOME/.$(printf "%s" "$i" | sed "s/.*\/\(.*\)/\1/g")"

        if [[ ! -e "$targetFile" ]]; then
            execute "ln -fs $sourceFile $targetFile" "$targetFile → $sourceFile"
        elif [ "$(readlink "$targetFile")" == "$sourceFile" ]; then
            print_success "$targetFile → $sourceFile"
        else 
            ask_for_confirmation "'$targetFile' already exists, do you want to overwrite it?"
            if answer_is_yes; then
                rm -rf "$targetFile"
                execute "ln -fs $sourceFile $targetFile" "$targetFile → $sourceFile"
            else
                print_error "$targetFile → $sourceFile"
            fi
        fi
    done

    unset FILES_TO_SYMLINK
}

main
