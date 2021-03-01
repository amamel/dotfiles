#!/bin/bash

# Fix timezone
sudo timedatectl set-timezone America/New_York

# Update system
sudo apt update -qq && sudo apt upgrade -yqq

# Install: basic packages
packages=(
  bash
  bpytop
  cmus
  curl
  fail2ban
  htop
  iftop
  jq
  make
  nodejs
  npm
  mosh
  nmap
  neofetch
  openssl
  pup
  python3
  rbenv
  reattach-to-user-namespace
  recode
  stow
  tor
  tmate
  tmux
  tree
  unbound
  ufw
  vim
  weechat
  wemux
  wget
  zsh
)
sudo apt-get install -yqq "${packages[@]}"

# Install tuxi
sudo curl -sL "https://raw.githubusercontent.com/Bugswriter/tuxi/main/tuxi" -o /usr/local/bin/tuxi
sudo chmod +x /usr/local/bin/tuxi

# Symlink dotfiles
stow git tmux vim

# Configure firewall for HTTP/HTTPS
sudo ufw enable
sudo ufw allow ssh
sudo ufw allow from 192.168.1.0/24
sudo ufw allow 80
sudo ufw allow 443

# configure Fail2ban
sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
sudo service fail2ban restart

sudo apt -yqq autoremove
sudo apt -yqq autoclean
echo "Done!"

echo "Download IOTstack"
# https://github.com/SensorsIot/IOTstack
curl -fsSL https://raw.githubusercontent.com/SensorsIot/IOTstack/master/install.sh | bash
echo "Done!"