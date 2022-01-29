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

    # console file editor
    apt install -y vim
    
    # install z shell
    apt install -y zsh
    apt install -y powerline fonts-powerline
        
    # change shell to zsh
    chsh -s $(which zsh) ${__username}
   
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
    
    # z shell configuration managero
    curl -fsS "https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh" | bash
    
    # sdkman - tool for multiple java / gradle etc. versions
    curl -fsS "https://get.sdkman.io" | bash
    source "${HOME}/.sdkman/bin/sdkman-init.sh"
    sdk version
    sdk install java
    sdk install gradle

    # Node Version Manager
    curl -fsS "https://raw.githubusercontent.com/nvm-sh/nvm/${__NVM_VER}/install.sh" | bash
    [ -s "${HOME}/.nvm/nvm.sh" ] && \. "${HOME}/.nvm/nvm.sh"  # This loads nvm
    nvm install node
    nvm alias default node
    
    # Rootless docker
    curl -fsS https://get.docker.com/rootless | bash
}


sudo bash -c "$(declare -f rootLevelInstallations); rootLevelInstallations"
zsh -c "$(declare -f userLevelInstallations); userLevelInstallations"
echo ""
echo "Seems script worked as intended"
