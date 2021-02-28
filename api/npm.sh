#!/usr/bin/env bash
# ****************************************************
#
#   Setup - NPM
#
# ****************************************************

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
  gulp-cli
  harp
  headstart
  homepress
  imageoptim-cli
  jade
  jasmine-node
  jets
  jshint
  localtunnel
  modernizr
  n
  nativescript
  parker
  postcss
  react
  sitespeed.io
  speed-test
  vtop
  vue
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