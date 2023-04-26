#!/usr/bin/env bash
#
# Script for installing various tools I use on fresh ubuntu
# Run as 
# 
#    sudo apt install -y curl && curl -fsS "https://raw.githubusercontent.com/zqbany/toolbox/main/ubuntu-init/ubuntu-install-tools.sh" | bash
#
set -o errexit
#set -o nounset // init files have unbound variables
set -o pipefail
# Uncomment for debugging
# set -o xtrace

readonly __username="$(whoami)"
readonly __user_progress_helper="${HOME}/.ubuntu_installation_script_progress_user"
declare -i current_processed=0
declare -i ever_processed=0
current_progress_filename=""
docker_test_mode=false

while getopts ":t" option; do
   case $option in
      t) # test without snaps
         docker_test_mode=true
   esac
done

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
    process apt-get -y update upgrade
    
    aptGetArray=()
    # ensure build essential is present
    aptGetArray+=("build-essential")
    
    # info about currently logged in users
    aptGetArray+=("finger")

    # console file editor
    aptGetArray+=("vim")
    
    # install powerline
    aptGetArray+=("powerline")
    aptGetArray+=("fonts-powerline")
   
    # install tree directories command
    aptGetArray+=("tree")

    # kitty terminal
    aptGetArray+=("kitty")

    # info about computer components
    aptGetArray+=("hwinfo")

    # command line network
    aptGetArray+=("curl")
    aptGetArray+=("httpie")

    # json parser & formatter
    aptGetArray+=("jq")

    # git
    aptGetArray+=("git")

    # commandline visual git
    aptGetArray+=("tig")
    
    # install via apt-get
    process apt-get -y install "${aptGetArray[@]}"

    # install snaps
    if [[ "${docker_test_mode}" = false ]] ; then
        #process apt-get install -y snapd
        process apt-get install -y gnome-software-plugin-snap

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
        process apt-get install -y uidmap
    fi
    
    # Clean the mess
    process apt-get -y autoremove
}

function installSdkMan {
    curl -fsS "https://get.sdkman.io" | bash
    source "${HOME}/.sdkman/bin/sdkman-init.sh"
}

function installHomebrew {
    curl -fsS "https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh" | bash
    (echo; echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"') >> "${HOME}/.profile"
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
}

function installNvm {
    brew install nvm
    mkdir ${HOME}/.nvm
    export NVM_DIR="$HOME/.nvm"
    [ -s "/home/linuxbrew/.linuxbrew/opt/nvm/nvm.sh" ] && \. "/home/linuxbrew/.linuxbrew/opt/nvm/nvm.sh"
    [ -s "/home/linuxbrew/.linuxbrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/home/linuxbrew/.linuxbrew/opt/nvm/etc/bash_completion.d/nvm"
}

function installDocker {
    curl -fsS https://get.docker.com/rootless | bash
    export "PATH=${HOME}/bin:\$PATH"
    export "DOCKER_HOST=unix:///run/user/1000/docker.sock"
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
    if [[ "${docker_test_mode}" = false ]] ; then
        process installDocker
    fi
    
    # Install zsh
    process brew install zsh
    
    # z shell configuration managero
    process installOhMyZsh
    
    zshrcTemplate >> "$HOME"/.zshrc
}

function zshrcTemplate {
    cat <<EOM
export LANG='en_US.UTF-8'
export LANGUAGE='en_US:en'
export LC_ALL='en_US.UTF-8'

eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

export NVM_DIR="\$HOME/.nvm"

[ -s "/home/linuxbrew/.linuxbrew/opt/nvm/nvm.sh" ] && \. "/home/linuxbrew/.linuxbrew/opt/nvm/nvm.sh"  # This loads nvm

[ -s "/home/linuxbrew/.linuxbrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/home/linuxbrew/.linuxbrew/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion

export PATH=${HOME}/bin:\$PATH

export DOCKER_HOST=unix:///run/user/1000/docker.sock

export SDKMAN_DIR="\$HOME/.sdkman"
[[ -s "\$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "\$HOME/.sdkman/bin/sdkman-init.sh"
EOM
}

# Install stuff
sudo bash -c "$(declare -f rootLevelInstallations); $(declare -f process); docker_test_mode=${docker_test_mode} rootLevelInstallations"
userLevelInstallations

# Change shell to zsh
process sudo chsh -s $(which zsh) ${__username}
    
echo ""
echo "Seems script worked as intended."
