# Add extra local config if it exists
function source_if_exists()
{
    if [[ -r $1 ]]; then
        source $1
    fi
}

# Tell Homebrew to not autoupdate every single time I run it (just once a week).
export HOMEBREW_AUTO_UPDATE_SECS=604800

## Init Zim framework for zsh
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

test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"