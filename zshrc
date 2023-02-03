# Set Variables
export NULLCMD=bat # Syntax highlighting for man pages using bat
export DOTFILES="$HOME/.dotfiles"
export HOMEBREW_BUNDLE_FILE="$DOTFILES/Brewfile"
export UPDATE_ZSH_DAYS=1

# Change ZSH Options
ZSH_THEME="agnoster"

# Adjust History Variables & Options
[[ -z $HISTFILE ]] && HISTFILE="$HOME/.zsh_history"
HISTSIZE=5000 # Session Memory Limit
SAVEHIST=4000 # File Memory Limit
setopt histNoStore
setopt extendedHistory
setopt histIgnoreAllDups
unsetopt appendHistory # explicit and unnecessary
setopt incAppendHistoryTime

# Line Editor Options (Completion, Menu, Directory, etc.)
# autoMenu & autoList are on by default
setopt autoCd
setopt globDots

# Create Aliases
alias ls='exa'
alias lsh='ls -lAd .*' #Show ONLY hidden files in the current directory
alias hid='ls -lAd .*'
alias exa='exa -laFh --git'
alias trail='<<<${(F)path}'
alias ftrail='<<<${(F)fpath}'
alias mkdir='mkdir -p'
alias rm=trash
alias man=batman
alias bbd='brew bundle dump --force --describe'
# Load history into shell (shareHistory alternative)
alias lh='fc -RI; echo "loaded and showing..."; history;' 
alias cd..='cd ..'
alias cd.....='cd ../../'
alias up='cd ../'
alias c='clear'
alias h='history'

alias zshreload="source ~/.zshrc"
alias zshconfig="mate ~/.zshrc"
alias ohmyzsh="mate ~/.oh-my-zsh"

# apache
alias ap2start='sudo service apache2 start'
alias ap2restart='sudo service apache2 restart'
alias ap2stop='sudo service apache2 stop'

# Git Commands
alias g='git'
alias gst='git status'

# Goto the root of the (git) directory.
alias groot='echo "I am Groot."; cd "$(git rev-parse --show-toplevel)"'

# Enable aliases to be sudo'ed
alias sudo=' sudo '

alias cask='brew cask'

# Recursively remove .DS_Store files
alias cleanupds="find . -type f -name '*.DS_Store' -ls -delete"

#source ~/.aliases # Source some extra files
#source ~/.functions

# Add Locations to $path Array
typeset -U path

path=(
  "$N_PREFIX/bin"
  $path
  "/Applications/Visual Studio Code - Insiders.app/Contents/Resources/app/bin"
)

# Use ZSH Plugins
ZSH_AUTOSUGGEST_STRATEGY=(history completion)

# source antidote
source <(antidote init)
antidote bundle < "$DOTFILES/antidote_plugins"
antidote update
antidote load