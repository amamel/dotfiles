# Append to path
export ZSH=$HOME/.oh-my-zsh
export NPM_PACKAGES="$HOME/.npm-packages"
export PATH="$NPM_PACKAGES/bin:$PATH"
export PATH="$HOME/.tuxi/bin:$PATH"
export PATH="$HOME/.rbenv/bin:$PATH"

export PATH="$HOME/GitHub/flutter/bin:$PATH"

export ANDROID_HOME=/Users/amamel/Library/Android/sdk 
export PATH="$ANDROID_HOME/tools:$PATH"
export PATH="$ANDROID_HOME/tools/bin:$PATH"
export PATH="$ANDROID_HOME/platform-tools:$PATH"


eval "$(rbenv init -)"
eval "$(starship init zsh)"

# Uncomment the following line to change how often to auto-update (in days).
export UPDATE_ZSH_DAYS=1

# Enable theme: Pure (https://github.com/sindresorhus/pure)
autoload -U promptinit; promptinit
prompt pure
ZSH_THEME=""

plugins=(colorize common-aliases git zsh-syntax-highlighting zsh-completions zsh-autosuggestions z)

# Path to your oh-my-zsh installation.
source $ZSH/oh-my-zsh.sh
source /usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

alias zshreload="source ~/.zshrc"
alias zshconfig="mate ~/.zshrc"
alias ohmyzsh="mate ~/.oh-my-zsh"
