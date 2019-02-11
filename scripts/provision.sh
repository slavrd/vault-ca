#!/usr/bin/env bash
# Install needed software and basic configs

[ "$1" == "" ] && V_USR="vagrant" || V_USR="$1"

# install
PKG="wget unzip curl jq vim sshpass"
which ${PKG} &>/dev/null || {
  export DEBIAN_FRONTEND=noninteractive
  sudo apt-get update >> /dev/null
  sudo apt-get install -y ${PKG} >> /dev/null
}

# Set .bash_profile to load .bashrc
grep '\.bashrc' ~/.bash_profile &>/dev/null || \
echo -e "\nif [ -f ~/.bashrc ]; then\n\tsource ~/.bashrc\nfi" | \
sudo tee -a ~/.bash_profile

grep '\.bashrc' /$V_USR/home/.bash_profile &>/dev/null || \
echo -e "\nif [ -f ~/.bashrc ]; then\n\tsource ~/.bashrc\nfi" | \
sudo tee -a /home/$V_USR/.bash_profile

sudo chown $V_USR /home/$V_USR/.bash_profile
