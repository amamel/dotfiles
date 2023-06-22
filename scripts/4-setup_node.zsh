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

# Checking if Node and NPM are already installed with `n`.
if exists $N_PREFIX/bin/node && exists $N_PREFIX/bin/npm; then
  echo "Node $($N_PREFIX/bin/node --version) & NPM $($N_PREFIX/bin/npm --version) already installed with n"
else
  echo "Installing Node & NPM with n..."
  if n latest; then
    echo "Node and NPM installation completed successfully."
  else
    echo "Failed to install Node and NPM with n."
    exit 1
  fi
fi

# Install Global NPM Packages

packages=(
  a11y             # Accessibility testing tools
  bigrig           # Performance analysis tool for websites
  black-screen     # Terminal emulator
  bower            # Package manager for the web
  browserify       # JavaScript module bundler
  browser-sync     # Synchronized browser testing
  csslint          # CSS code quality tool
  cssnext          # Future CSS syntax compatibility
  express          # Web application framework
  foldingtext      # Plain text productivity tool
  forever          # Process manager for Node.js applications
  gatsby-cli       # Command-line tool for Gatsby.js
  gh               # GitHub CLI
  @gridsome/cli    # Static site generator for Vue.js
  gulp             # Task runner
  gulp-cli         # Gulp command-line interface
  harp             # Static web server
  headstart        # HTML template generator
  imageoptim-cli   # Image optimization tool
  jade             # Template engine
  jasmine-node     # Testing framework for Node.js
  jets             # Serverless framework for Ruby
  jshint           # JavaScript code quality tool
  localtunnel      # Expose local server to the internet
  @googlemaps/google-maps-services-js  # Google Maps API client
  meteor --save react react-dom  # Meteor framework with React
  n                # Node.js version management
  nativescript     # Open-source framework for building native mobile apps
  parker           # Stylesheet analysis tool
  postcss          # CSS post-processor
  react            # JavaScript library for building user interfaces
  sitespeed.io     # Web performance testing and monitoring
  spoof            # Network traffic interception and modification
  speed-test       # Internet connection speed testing
  vtop             # Terminal activity monitor
  vue-cli          # Vue.js command-line interface
  yarn             # Package manager
)

echo '
========================================
Installing packages
========================================'
for package in ${packages[@]}; do
  echo "Installing $package..."
  if npm install -g $package; then
    echo "$package installed successfully."
  else
    echo "Failed to install $package."
    exit 1
  fi
done

echo '
========================================
Updating packages
========================================'
for package in ${packages[@]}; do
  echo "Updating $package..."
  if npm update -g $package; then
    echo "$package updated successfully."
  else
    echo "Failed to update $package."
    exit 1
  fi
done

echo '
========================================
npm Installation complete
========================================'
