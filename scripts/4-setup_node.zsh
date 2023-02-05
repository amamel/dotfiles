#!/usr/bin/env zsh
# ****************************************************
#
#   Setup - NPM
#
# ****************************************************

echo "\n<<< Starting Node Setup >>>\n"

# Node versions are managed with `n`, which is in the Brewfile.
# See `zshenv` for the setting of the `N_PREFIX` variable,
# thus making it available below during the first install.
# See `zshrc` where `N_PREFIX/bin` is added to `$path`.

if exists $N_PREFIX/bin/node; then
  echo "Node $($N_PREFIX/bin/node --version) & NPM $($N_PREFIX/bin/npm --version) already installed with n"
else
  echo "Installing Node & NPM with n..."
  n latest
fi


# Install Global NPM Packages

packages=(
  a11y
  bigrig
  black-screen
  bower
  browserify
  browser-sync
  csslint
  cssnext
  express
  foldingtext
  forever
  gatsby-cli
  gh
  @gridsome/cli
  gulp
  gulp-cli
  harp
  headstart
  imageoptim-cli
  jade
  jasmine-node
  jets
  jshint
  localtunnel
  @googlemaps/google-maps-services-js
  meteor --save react react-dom
  n
  nativescript
  parker
  postcss
  react
  sitespeed.io
  speed-test
  vtop
  vue-cli
  yarn
)
echo '
========================================
Installing packages
========================================'
for package in ${packages[@]}; do
  npm install -g $package
done

echo '
========================================
Updating packages
========================================'
for package in ${packages[@]}; do
  npm update -g $package
done

echo '
========================================
npm Installation complete
========================================'
