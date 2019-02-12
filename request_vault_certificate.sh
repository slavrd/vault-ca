#!/usr/bin/env bash
# requests a cerificate from vault and isntalls it with a test site in nginx
# Optional: 1st argument: CN for the certificate. Default "test.my-domain.com"
# Requires: Vault address and Vault token set to $VAULT_ADDR and $VAULT_TOKEN

[ "$1" == "" ] && CERT_CN="test.my-domain.com" || CERT_CN="$1"

VAULT_RESP_FILE="/tmp/vault_response.json"

# request certificate from Vault
curl \
    --header "X-Vault-Token: $VAULT_TOKEN" \
    --request "POST" \
    --data "{ \"common_name\": \"$CERT_CN\", \"ttl\": \"24h\" }" \
    $VAULT_ADDR/v1/pki_int/issue/cert-req \
    | jq -r .data > $VAULT_RESP_FILE

# parse vault response and install chainde certificates and key
jq -r '.certificate' $VAULT_RESP_FILE | sudo tee /etc/ssl/certs/vault_certificate.crt > /dev/null
jq -r '.ca_chain[]' $VAULT_RESP_FILE | sudo tee -a /etc/ssl/certs/vault_certificate.crt > /dev/null
jq -r '.private_key' $VAULT_RESP_FILE | sudo tee -a /etc/ssl/private/vault_certificate.key > /dev/null

# clean up response file
rm $VAULT_RESP_FILE

# configure ngnix site to use the certificate
sudo cp /vagrant/ngnix-conf/test.my-domain.com /etc/nginx/sites-available/.
sudo ln -s /etc/nginx/sites-available/test.my-domain.com /etc/nginx/sites-enabled/test.my-domain.com
sudo service nginx restart
