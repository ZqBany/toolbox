#!/usr/bin/env bash
# 
# VBoxManage startvm "Ubuntu 22.04"
#

set -o errexit
set -o nounset
set -o pipefail
# Uncomment for debugging
# set -o xtrace

readonly __version="22.04"
readonly __isoname="ubuntu-${__version}.2-desktop-amd64.iso"

function installVirtualbox {
    apt-get -y update
    apt-get -y install virtualbox
    apt-get -y install virtualbox-ext-pack
}

function downloadUbuntuISO {
    if [ ! -f "${__isoname}" ]; then
        http --download "https://releases.ubuntu.com/jammy/${__isoname}"
    fi
}

function createUbuntuVM {
    VBoxManage createvm --name "Ubuntu ${__version}" --ostype Ubuntu_64 --register
    VBoxManage modifyvm "Ubuntu ${__version}" --cpus 2 --memory 4096 --vram 128 --graphicscontroller vmsvga --usbohci on --mouse usbtablet
}

function addUbuntuVMStorage {
    VBoxManage createhd --filename "~/VirtualBox VMs/Ubuntu ${__version}/Ubuntu ${__version}.vdi" --size 20480 --variant Standard
    VBoxManage storagectl "Ubuntu ${__version}" --name "SATA Controller" --add sata --bootable on
    VBoxManage storageattach "Ubuntu ${__version}" --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium "~/VirtualBox VMs/Ubuntu ${__version}/Ubuntu ${__version}.vdi"
}

function addDvdDriveForIso {
    VBoxManage storagectl "Ubuntu ${__version}" --name "IDE Controller" --add ide
    VBoxManage storageattach "Ubuntu ${__version}" --storagectl "IDE Controller" --port 0 --device 0 --type dvddrive --medium "${__isoname}"
}

function prepareVM {
    downloadUbuntuISO
    createUbuntuVM
    addUbuntuVMStorage
    addDvdDriveForIso
    VBoxManage setextradata "Ubuntu ${__version}" GUI/ScaleFactor 2
}

command -v VBoxManage || sudo bash -c "$(declare -f installVirtualbox); installVirtualbox"
VBoxManage showvminfo "Ubuntu ${__version}" || prepareVM

