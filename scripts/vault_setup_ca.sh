#!/usr/bin/env bash
# Setup Vault CA authority
# Requires packages - jq
# Optional - 1st argument - root domain name. Defaults to "my-domain.com"

[ "$1" == "" ] && ROOT_DOMAIN="my-domain.com" || ROOT_DOMAIN=$1

# enable pki secret engine for the Root CA
vault secrets enable -path=pki_root pki
vault secrets tune -max-lease-ttl=87600h pki_root >/dev/null

# generate the root certificate 
vault write -field=certificate pki_root/root/generate/internal common_name="$ROOT_DOMAIN" \
    ttl=87600h > $HOME/root_ca_cert.crt
echo "Root CA certificate is in $HOME/root_ca_cert.crt"

# configure root CA's issuing and crl distribution urls
vault write pki_root/config/urls \
       issuing_certificates="http://127.0.0.1:8200/v1/pki_root/ca" \
       crl_distribution_points="http://127.0.0.1:8200/v1/pki_root/crl"

# create the Intermediate CA
vault secrets enable -path=pki_int pki
vault secrets tune -max-lease-ttl=43800h pki_int >/dev/null

# generate CSR for intermediate CA
vault write -format=json pki_int/intermediate/generate/internal \
    common_name="$ROOT_DOMAIN Intermediate Authority" ttl="43800h" \
    | jq -r '.data.csr' > $HOME/pki_intermediate.csr

# sign the CSR with the root CA's certificate
vault write -format=json pki_root/root/sign-intermediate csr=@$HOME/pki_intermediate.csr \
    format=pem_bundle \
    | jq -r '.data.certificate' > $HOME/intermediate.cert.pem

# import the signed intermediate CSR
vault write pki_int/intermediate/set-signed certificate=@$HOME/intermediate.cert.pem

# create a role that conrols the leaf certificates which will be issued
vault write pki_int/roles/cert-req \
    allowed_domains="$ROOT_DOMAIN" \
    allow_subdomains=true \
    max_ttl="720h"
