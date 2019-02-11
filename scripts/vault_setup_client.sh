#!/usr/bin/env bash
# Sets up user environment variables for the vault client
# Required: 1st argument - vault server IP
# Optional: 2nd argument. Defaults to vagrant.
# Required: packages - sshpass

[ "$2" == "" ] && V_USR="vagrant" || V_USR="$2"

# add vault server address
grep VAULT_ADDR /home/$V_USR/.bash_profile || {
  echo export VAULT_ADDR="http://$1:8200" | sudo tee -a /home/$V_USR/.bash_profile
}

# add vault token from the provided vault server
grep VAULT_TOKEN /home/$V_USR/.bash_profile || {
  echo "export VAULT_TOKEN=\$(sshpass -p vagrant ssh -o StrictHostKeyChecking=no vagrant@$1 \"sudo cat /root/.vault-token\")" | \
    sudo tee -a /home/$V_USR/.bash_profile
}
