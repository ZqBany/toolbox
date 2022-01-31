#!/usr/bin/env bash
#
# Script for installing various tools I use on fresh ubuntu
# Run as 
# 
#    sudo apt install -y curl && curl -fsS "https://raw.githubusercontent.com/zqbany/toolbox/main/ubuntu.sh" | bash
#
set -o errexit
set -o nounset
set -o pipefail
# Uncomment for debugging
# set -o xtrace

readonly __username="$(whoami)"

echo "Username: ${__username}"

function rootLevelInstallations {
    echo "Performing root level as $(whoami)"

    # update & upgrade
    apt update
    apt -y upgrade
    
    # ensure build essential is present
    apt install build-essential

    # console file editor
    apt install -y vim
    
    # install powerline
    apt install -y powerline fonts-powerline
   
    # install tree directories command
    apt install -y tree

    # kitty terminal
    apt install -y kitty

    # info about computer components
    apt install -y hwinfo

    # command line network
    apt install -y curl

    # json parser & formatter
    apt install -y jq

    # git
    apt install -y git

    # commandline visual git
    apt install -y tig

    # install snaps
    apt install -y snapd
    apt install -y gnome-software-plugin-snap

    # visual studio code
    snap install code --classic

    # strechly - reminders about moving your ass from keyboard
    snap install stretchly

    # IntelliJ IDEA Comminuty
    snap install intellij-idea-community --classic

    # rest client
    snap install insomnia

    # keepass XC - password manager
    snap install keepassxc

    # slack
    snap install slack --classic
    
    # For docker rootless install
    apt install -y uidmap
    
    # Clean the mess
    apt -y autoremove
}

function userLevelInstallations {
    echo "Performing user level as $(whoami)"

    readonly __NVM_VER="v0.39.1"
    
    # sdkman - tool for multiple java / gradle etc. versions
    curl -fsS "https://get.sdkman.io" | bash
    source "${HOME}/.sdkman/bin/sdkman-init.sh"
    sdk version
    sdk install java
    sdk install gradle

    # Homebrew
    curl -fsS "https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh" | bash
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    
    # Mongo cli
    brew install mongosh
    
    # Node Version Manager
    brew install nvm
    nvm install node
    nvm alias default node
    
    # Rootless docker
    curl -fsS https://get.docker.com/rootless | bash
    # TODO add docker host to zshrc by cli
    
    # Install zsh
    brew install zsh
    
    # z shell configuration managero
    curl -fsS "https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh" | bash
}

# Install stuff
sudo bash -c "$(declare -f rootLevelInstallations); rootLevelInstallations"
userLevelInstallations

# Change shell to zsh
sudo chsh -s $(which zsh) ${__username}
    
echo ""
echo "Seems script worked as intended. Export brew host and docker host var to your ~/.zshrc as seen above"
