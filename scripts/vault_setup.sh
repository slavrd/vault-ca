#!/usr/bin/env bash
# start and setup Vault

[ "$1" == "" ] && V_USR="vagrant" || V_USR="$1"

VAULT=0.11.4
# check vault binary
which vault &>/dev/null || {
  pushd /usr/local/bin
  [ -f vault_${VAULT}_linux_amd64.zip ] || {
    sudo wget -q https://releases.hashicorp.com/vault/${VAULT}/vault_${VAULT}_linux_amd64.zip
  }
  sudo unzip vault_${VAULT}_linux_amd64.zip >> /dev/null
  sudo chmod +x vault
  popd
}

# set vault log destination
if [ -d /vagrant ]; then
  [ -d /vagrant/logs ] || mkdir /vagrant/logs
  LOG="/vagrant/logs/vault_${HOSTNAME}.log"
else
  LOG="vault.log"
fi

# kill past instance
sudo killall vault &>/dev/null

# delete old token if present
[ -f ~/.vault-token ] && sudo rm ~/.vault-token

# start vault
/usr/local/bin/vault server  -dev -dev-listen-address=0.0.0.0:8200  &> ${LOG} &
echo vault started
sleep 3 

# make sure the current token is used
export VAULT_TOKEN="`sudo cat ~/.vault-token`"

# set vault address 
export VAULT_ADDR="http://127.0.0.1:8200"

# set VAULT_ADDR for root and other users
grep VAULT_ADDR ~/.bash_profile || {
  echo export VAULT_ADDR=http://127.0.0.1:8200 | sudo tee -a ~/.bash_profile
}

grep VAULT_ADDR /home/$V_USR/.bash_profile || {
  echo export VAULT_ADDR=http://127.0.0.1:8200 | sudo tee -a /home/$V_USR/.bash_profile
}

# set VAULT_TOKEN
echo "vault token:"
cat ~/.vault-token
echo -e "\nvault token is on $HOME/.vault-token"

grep VAULT_TOKEN ~/.bash_profile || {
  echo export VAULT_TOKEN=\`sudo cat ~/.vault-token\` | sudo tee -a ~/.bash_profile
}

grep VAULT_TOKEN /home/$V_USR/.bash_profile || {
  echo export VAULT_TOKEN=\`sudo cat ~/.vault-token\` | sudo tee -a /home/$V_USR/.bash_profile
}
