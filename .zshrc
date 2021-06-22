# Path to your oh-my-zsh installation.
export ZSH=~/.oh-my-zsh

ZSH_THEME="agnoster"

COMPLETION_WAITING_DOTS="true"

plugins=(git osx extract z sublime docker rails web-search vagrant)

ZSH_DISABLE_COMPFIX=true
source $ZSH/oh-my-zsh.sh

# SSH
export SSH_KEY_PATH="~/.ssh/rsa_id"
LC_CTYPE=en_US.UTF-8
LC_ALL=en_US.UTF-8

# Include alias file (if present)
if [ -f ~/.aliases ]
then
  source ~/.aliases
fi

export PATH="/usr/local/sbin:$PATH"
export PATH="$HOME/.composer/vendor/bin:$PATH"

# Autocompletion for sshrc
compdef sshrc=ssh

source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh

eval "$(rbenv init -)"

if command -v pyenv 1>/dev/null 2>&1; then
  eval "$(pyenv init -)"
fi

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# Tell Homebrew to not autoupdate every single time I run it (just once a week).
export HOMEBREW_AUTO_UPDATE_SECS=604800

# Add extra local zshrc config if it exists
function source_if_exists()
{
    if [[ -r $1 ]]; then
        source $1
    fi
}

source_if_exists ~/.zshrc.extra