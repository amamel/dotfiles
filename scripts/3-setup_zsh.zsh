#!/usr/bin/env zsh

echo "\n<<< Starting ZSH Setup >>>\n"

# No installation necessary; assuming it's already in Brewfile.

# Checking if '/usr/local/bin/zsh' is already present in '/etc/shells'.
if grep -Fxq '/usr/local/bin/zsh' '/etc/shells'; then
  echo '/usr/local/bin/zsh' is already in '/etc/shells'.
else
  echo "Enter superuser (sudo) password to edit /etc/shells"
  echo '/usr/local/bin/zsh' | sudo tee -a '/etc/shells' >/dev/null
fi

# Checking if the current shell is already set to '/usr/local/bin/zsh'.
if [ "$SHELL" = '/usr/local/bin/zsh' ]; then
  echo '$SHELL is already set to /usr/local/bin/zsh'
else
  echo "Enter user password to change login shell"
  chsh -s '/usr/local/bin/zsh'
fi

# Checking if '/private/var/select/sh' is already linked to '/bin/zsh'.
if [[ -L /private/var/select/sh && $(readlink /private/var/select/sh) = '/bin/zsh' ]]; then
  echo '/private/var/select/sh' is already linked to '/bin/zsh'
else
  echo "Enter superuser (sudo) password to symlink sh to zsh"
  # Creating a symbolic link from '/bin/zsh' to '/private/var/select/sh'.
  sudo ln -sfv /bin/zsh /private/var/select/sh
fi
