#!/usr/bin/env bash
# Configure the web client
# Required: 1st argument - vault server IP
# Required: 2nd argument - web server IP
# Optional: 3rd argument - dns entry for web server. Defaults to test.my-domain.com
# Required: packages - sshpass

[ "$3" == "" ] && DNS_ADDR="test.my-domain.com" || DNS_ADDR="$3"

# add Vault's Root CA cert to trusted store
sshpass -p vagrant ssh -o StrictHostKeyChecking=no vagrant@$1 sudo cat /root/root_ca_cert.crt | sudo tee /usr/local/share/ca-certificates/vault_ca.crt >>/dev/null
sudo update-ca-certificates

# add DNS entry for web server
echo "$2 $DNS_ADDR" | sudo tee -a /etc/hosts