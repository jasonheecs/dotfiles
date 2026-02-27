# Add extra local config if it exists
source_if_exists()
{
    [[ -f "$1" ]] && source "$1"
}

# Path to your oh-my-zsh installation.
export ZSH=~/.oh-my-zsh

ZSH_THEME="agnoster"

COMPLETION_WAITING_DOTS="true"

plugins=(git macos web-search vagrant)

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
export NODE_EXTRA_CA_CERTS="$(brew --prefix)/etc/ca-certificates/cert.pem"

# Autocompletion for sshrc
compdef sshrc=ssh

source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
eval "$(rbenv init -)"
eval "$(fnm env --use-on-cd)"

# Tell Homebrew to not autoupdate every single time I run it (just once a week).
export HOMEBREW_AUTO_UPDATE_SECS=604800

# Init Zim framework for zsh
HOME_DIR=${ZDOTDIR:-${HOME}}
ZIM_HOME=${HOME_DIR}/.zim

# Install missing modules and update ${ZIM_HOME}/init.zsh if missing or outdated.
if [[ ! ${ZIM_HOME}/init.zsh -nt ${ZIM_CONFIG_FILE:-${HOME_DIR}/.zimrc} ]]; then
  source $(brew --prefix)/opt/zimfw/share/zimfw.zsh init
fi
# Initialize modules.
source ${ZIM_HOME}/init.zsh

eval "$(rbenv init -)"
eval "$(fnm env --use-on-cd)"
eval "$(pyenv init -)"

source_if_exists ~/.aliases
source_if_exists ~/.zshrc.extra
source_if_exists ~/.iterm2_shell_integration.zsh