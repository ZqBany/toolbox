#!/usr/bin/env bash
#
# Script for installing various tools I use on fresh ubuntu
# Run as 
# sudo ./ubuntu.sh `whoami`
#
set -o errexit
set -o nounset
set -o pipefail
# Uncomment for debugging
# set -o xtrace

readonly __dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly __file="${__dir}/$(basename "${BASH_SOURCE[0]}")"
readonly __base="$(basename ${__file} .sh)"

readonly __username="$1"

pushd "${__dir}" 
echo "Username: ${__username}"

function rootLevelInstallations {
    # update
    apt update

    # console file editor
    apt install vim
    
    # install z shell
    apt install zsh
    apt install powerline fonts-powerline
    
        
    # change shell to zsh
    chsh -s $(which zsh) ${__username}
   
    # install tree directories command
    apt install tree

    # kitty terminal
    apt install kitty

    # info about computer components
    apt install hwinfo

    # command line network
    apt install curl

    # json parser & formatter
    apt install jq

    # git
    apt install git

    # commandline visual git
    apt install tig

    # install snaps
    apt install snapd

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
}

function userLevelInstallations {

    readonly __NVM_VER="v0.39.1"
    
    # z shell configuration managero
    curl -fsS "https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh" | bash
    
    # sdkman - tool for multiple java / gradle etc. versions
    curl -fsS "https://get.sdkman.io" | bash
    source "${HOME}/.sdkman/bin/sdkman-init.sh"
    sdk install java
    sdk install gradle

    # Node Version Manager
    curl -fsS "https://raw.githubusercontent.com/nvm-sh/nvm/${__NVM_VER}/install.sh" | bash
    [ -s "${HOME}/.nvm/nvm.sh" ] && \. "${HOME}/.nvm/nvm.sh"  # This loads nvm
    nvm install node
    nvm alias default node
}

export -f userLevelInstallations

rootLevelInstallations
su "${__username}" -c "bash -c userLevelInstallations"

popd # __dir
