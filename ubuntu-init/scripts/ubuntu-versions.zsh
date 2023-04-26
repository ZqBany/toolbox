#!/usr/bin/env zsh
#
# Script for installing various tools I use on fresh ubuntu
# Run as 
# 
#    cat ./ubuntu-versions.sh | zsh
#
# Uncomment for debugging
# set -o xtrace

readonly __username="$(whoami)"
readonly __shell="$(finger $__username|grep -oP 'Shell: \K.*')"

source "$HOME/.zshrc"

function maybeVersion {
    command -v $3 > /dev/null && ("${@:3}" | awk "NR==$1{print \$$2}") || echo "uninstalled"
}

function getVersions {
    versions_json=$(jq -n \
              --arg vim "$(maybeVersion 1 5 vim --version)" \
              --arg kitty $(maybeVersion 1 2 kitty --version) \
              --arg hwinfo $(maybeVersion 1 1 hwinfo --version) \
              --arg curl $(maybeVersion 1 2 curl --version) \
              --arg http $(maybeVersion 1 1 http --version) \
              --arg jq $(maybeVersion 1 1 jq --version) \
              --arg git $(maybeVersion 1 3 git --version) \
              --arg tig $(maybeVersion 1 3 tig --version) \
              --arg snap $(maybeVersion 2 2 snap --version) \
              --arg code $(maybeVersion 2 2 snap list code) \
              --arg stretchly $(maybeVersion 2 2 snap list stretchly) \
              --arg intellij-idea-community $(maybeVersion 2 2 snap list intellij-idea-community) \
              --arg insomnia $(maybeVersion 2 2 snap list insomnia) \
              --arg keepassxc $(maybeVersion 2 2 snap list keepassxc) \
              --arg slack $(maybeVersion 2 2 snap list slack) \
              --arg sdk $(maybeVersion 3 2 sdk version) \
              --arg java $(maybeVersion 2 4 sdk current java) \
              --arg gradle $(maybeVersion 2 4 sdk current gradle) \
              --arg brew $(maybeVersion 1 2 brew --version) \
              --arg mongosh $(maybeVersion 1 1 mongosh --version) \
              --arg nvm $(maybeVersion 1 1 nvm --version) \
              --arg zsh $(maybeVersion 1 2 zsh --version) \
              --arg docker $(maybeVersion 1 3 docker --version) \
              '$ARGS.named')
    echo "${versions_json}" | jq .
}
                           
getVersions
