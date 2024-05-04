#!/usr/bin/env zsh

echo "\n<<< Starting Homebrew Setup >>>\n"

if exists brew; then
  echo "› Homebrew exists! Skipping install."
else
  echo "› Brew doesn't exist, continuing with install..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# TODO: Keep an eye out for a different `--no-quarantine` solution.

# Currently, you can't do `brew bundle --no-quarantine` as an option.
# export HOMEBREW_CASK_OPTS="--no-quarantine --no-binaries"
# https://github.com/Homebrew/homebrew-bundle/issues/474

# HOMEBREW_CASK_OPTS is exported in `zshenv` with
# `--no-quarantine` and `--no-binaries` options,
# which makes them available to Homebrew for the
# first install (before our `zshrc` is sourced).

echo "› Updating Homebrew..."
brew update

echo "› Upgrading Packages..."
brew upgrade

echo "› Installing Mac App Store CLI..."
brew install mas

echo "› Pouring brews... (this could take a while)"
brew bundle --verbose

echo "› Cleaning up Homebrew..."
brew cleanup

# Should we wrap this in a conditional?
echo "› Enter superuser (sudo) password to accept Xcode license"
sudo xcodebuild -license accept
sudo xcodebuild -runFirstLaunch

# Install VS Code extensions
echo "› Installing VS Code Extensions"
cat vscode/extensions.txt | xargs -L 1 code --install-extension

# This works to solve the Insecure Directories issue:
# compaudit | xargs chmod go-w
# But this is from the Homebrew site, though `-R` was needed:
# https://docs.brew.sh/Shell-Completion#configuring-completions-in-zsh
echo "› Fixing insecure directories..."
chmod -R go-w "$(brew --prefix)/share"
