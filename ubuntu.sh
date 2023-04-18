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
readonly __user_progress_helper="${HOME}/.ubuntu_installation_script_progress_user"
declare -i current_processed=0
declare -i ever_processed=0
current_progress_filename=""

echo "Username: ${__username}"


function process {
    if [ "${current_processed}" -ge "${ever_processed}" ]; then
        "$@"
        ever_processed=$((ever_processed+1))
        echo "${ever_processed}" > ${current_progress_filename}
    else
        echo "#${current_processed} skipping $@"
    fi
    current_processed=$((current_processed+1))
}

function rootLevelInstallations {
    readonly __admin_progress_helper="${HOME}/.ubuntu_installation_script_progress_admin"

    echo "Performing root level as $(whoami)"
    
    current_processed=0
    ever_processed=0
    current_progress_filename="${__admin_progress_helper}"
    echo "Current file: ${__admin_progress_helper}"
    [ -s "${current_progress_filename}" ] && declare -i ever_processed=$(cat ${current_progress_filename})
    
    # update & upgrade
    process apt update
    process apt -y upgrade
    
    # ensure build essential is present
    process apt install build-essential

    # console file editor
    process apt install -y vim
    
    # install powerline
    process apt install -y powerline fonts-powerline
   
    # install tree directories command
    process apt install -y tree

    # kitty terminal
    process apt install -y kitty

    # info about computer components
    process apt install -y hwinfo

    # command line network
    process apt install -y curl
    process apt install -y httpie

    # json parser & formatter
    process apt install -y jq

    # git
    process apt install -y git

    # commandline visual git
    process apt install -y tig

    # install snaps
    process apt install -y snapd
    process apt install -y gnome-software-plugin-snap

    # visual studio code
    process snap install code --classic

    # strechly - reminders about moving your ass from keyboard
    process snap install stretchly

    # IntelliJ IDEA Comminuty
    process snap install intellij-idea-community --classic

    # rest client
    process snap install insomnia

    # keepass XC - password manager
    process snap install keepassxc

    # slack
    process snap install slack --classic
    
    # For docker rootless install
    process apt install -y uidmap
    
    # Clean the mess
    process apt -y autoremove
}

function installSdkMan {
    curl -fsS "https://get.sdkman.io" | bash
    set +o nounset
    source "${HOME}/.sdkman/bin/sdkman-init.sh"
    set -o nounset
}

function installHomebrew {
    curl -fsS "https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh" | bash
    set +o nounset
    (echo; echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"') >> ${HOME}/.profile
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    set -o nounset
}

function installNvm {
    brew install nvm
    mkdir ${HOME}/.nvm
    (echo; echo 'export NVM_DIR="$HOME/.nvm"') >> ${HOME}/.profile
    (echo; echo '[ -s "/home/linuxbrew/.linuxbrew/opt/nvm/nvm.sh" ] && \. "/home/linuxbrew/.linuxbrew/opt/nvm/nvm.sh"  # This loads nvm') >> ${HOME}/.profile
    (echo; echo '[ -s "/home/linuxbrew/.linuxbrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/home/linuxbrew/.linuxbrew/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion') >> ${HOME}/.profile
    source ${HOME}/.profile
}

function installDocker {
    curl -fsS https://get.docker.com/rootless | bash
    (echo; echo 'export PATH=/home/zqbany/bin:$PATH') >> ${HOME}/.profile
    (echo; echo 'export DOCKER_HOST=unix:///run/user/1000/docker.sock') >> ${HOME}/.profile
    source ${HOME}/.profile
}

function installOhMyZsh {
    curl -fsS "https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh" | bash
}

function userLevelInstallations {
    echo "Performing user level as $(whoami)"
    
    current_processed=0
    ever_processed=0
    current_progress_filename="${__user_progress_helper}"
    [ -s "${current_progress_filename}" ] && ever_processed=$(cat ${current_progress_filename})
    
    # sdkman - tool for multiple java / gradle etc. versions
    process installSdkMan
    process sdk version
    process sdk install java
    process sdk install gradle

    # Homebrew
    process installHomebrew
    
    # Mongo cli
    process brew install mongosh
    
    # Node Version Manager
    process installNvm
    process nvm install node
    process nvm alias default node
    
    # Rootless docker
    process installDocker
    
    # Install zsh
    process brew install zsh
    
    # z shell configuration managero
    process installOhMyZsh
}

# Install stuff
sudo bash -c "$(declare -f rootLevelInstallations); $(declare -f process); rootLevelInstallations"
userLevelInstallations

# Change shell to zsh
process sudo chsh -s $(which zsh) ${__username}
    
echo ""
echo "Seems script worked as intended. Export brew host and docker host var to your ~/.zshrc as seen above"
