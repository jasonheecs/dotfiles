# Add extra local config if it exists
source_if_exists()
{
    [[ -f "$1" ]] && source "$1"
}

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

(( $+commands[rbenv] )) && eval "$(rbenv init -)"
(( $+commands[fnm] )) && eval "$(fnm env --use-on-cd)"
(( $+commands[pyenv] )) && eval "$(pyenv init -)"

# pnpm
export PNPM_HOME="${HOME}/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

source_if_exists ~/.aliases
source_if_exists ~/.zshrc.extra
source_if_exists ~/.iterm2_shell_integration.zsh
