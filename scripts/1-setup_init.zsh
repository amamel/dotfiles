#!/usr/bin/env zsh

###############################################################################
# ERROR: Let the user know if the script fails
###############################################################################

trap 'ret=$?; test $ret -ne 0 && printf "\n   \e[31m\033[0m  Script failed  \e[31m\033[0m\n" >&2; exit $ret' EXIT

set -e

###############################################################################
# Begin Setup
###############################################################################
printf "
_________       _____ _____________ ______              
______  /______ __  /____  __/___(_)___  /_____ ________
_  __  / _  __ \_  __/__  /_  __  / __  / _  _ \__  ___/
/ /_/ /  / /_/ // /_  _  __/  _  /  _  /  /  __/_(__  ) 
\__,_/   \____/ \__/  /_/     /_/   /_/   \___/ /____/  
╭───────────────────────────────────────────────────╮
│ System dotfiles automation                        │
│───────────────────────────────────────────────────│
│  Safe to run multiple times on the same machine.  │
│  It installs, upgrades, or skips packages based   │
│  on what is already installed on the machine.     │
╰───────────────────────────────────────────────────╯
"