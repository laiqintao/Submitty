#!/usr/bin/env bash

# this script must be run by root or sudo
if [[ "$UID" -ne "0" ]] ; then
    echo "ERROR: This script must be run by root or sudo"
    exit
fi

SOURCE="${BASH_SOURCE[0]}"
CURRENT_DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
DISTRO=$(lsb_release -si | tr '[:upper:]' '[:lower:]')
VERSION=$(lsb_release -sc | tr '[:upper:]' '[:lower:]')

if [ ! -d ${CURRENT_DIR}/${DISTRO} ]; then
    (>&2 echo "Unknown distro: ${DISTRO}")
    exit 1
fi

echo "====Setting up distro===="
lsb_release -ri
echo "========================="

RUN_DIR=${CURRENT_DIR}/${DISTRO}/${VERSION}
source ${RUN_DIR}/setup_distro.sh

# Read through our arguments to get "extra" packages to install for our distro
# ${@} are populated by whatever calls install_system.sh which then sources this
# script.
IFS=',' read -ra ADDR <<< "${@}"
if [ ${#ADDR[@]} ]; then
    echo "Installing extra packages..."
    for i in "${ADDR[@]}"; do
        if [ -f ${RUN_DIR}/${i}.sh ]; then
            echo "Running ${RUN_DIR}/${i}.sh"
            source ${RUN_DIR}/${i}.sh
        else
            echo "Could not find ${i}.sh for ${DISTRO}"
        fi
    done
fi
