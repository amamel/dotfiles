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
  make
  nodejs
  npm
  mosh
  nmap
  neofetch
  openssl
  python3
  rbenv
  reattach-to-user-namespace
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