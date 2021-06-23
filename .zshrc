# Add extra local config if it exists
function source_if_exists()
{
    if [[ -r $1 ]]; then
        source $1
    fi
}

# Path to your oh-my-zsh installation.
export ZSH=~/.oh-my-zsh

ZSH_THEME="agnoster"

COMPLETION_WAITING_DOTS="true"

plugins=(git osx extract z sublime docker rails web-search vagrant)

ZSH_DISABLE_COMPFIX=true
source_if_exists $ZSH/oh-my-zsh.sh

# SSH
export SSH_KEY_PATH="~/.ssh/rsa_id"
LC_CTYPE=en_US.UTF-8
LC_ALL=en_US.UTF-8

# Include alias file (if present)
source_if_exists ~/.aliases

export PATH="/usr/local/sbin:$PATH"
export PATH="$HOME/.composer/vendor/bin:$PATH"

source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh

eval "$(pyenv init -)"
eval "$(rbenv init -)"

# Tell Homebrew to not autoupdate every single time I run it (just once a week).
export HOMEBREW_AUTO_UPDATE_SECS=604800

source_if_exists ~/.zshrc.extra
test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"
