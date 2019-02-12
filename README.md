# Vault CA

A Vagrant project with basic demonstration of Vault's pki (certificate) secrets engine.

The projects builds 3 VMs

1. Vault server. It acts as a root CA which sings the certificate for an intermediate CA. The Intermediate CA is used to issue leaf certificates to Vault's clients via the pki secrets engine.
2. Web server. It requests a leaf certificate from Vault and then configures it to be used by an nginx web server.
3. Client server. It consumes the site hosted by the web server.

## Prerequisites

* Install VirtualBox - [instructions](https://www.virtualbox.org/wiki/Downloads)
* Install Vagrant - [instructions](https://www.vagrantup.com/downloads.html)

## Building the project

* Run `vagrant up` to build the 3 VMs.

At this point:

* The Vault server vm - `vault01` will have: 
  * Vault server installed and configured with pki secrets engine. Login to the server - `vagrant ssh vault01`
  * A pki engine instance enabled at path `pki_root`. It acts as the root CA. The CA's public key is in `/root/root_ca_cert.crt`
  * A pki engine instance enabled at path `pki_int`. It acts as an intermediate CA with its certificate signed by the root.
  * A vault role `cert-req` configured on the Intermediate CA that allows requesting certificates for `my-domain.com` incl. sub-domains.

Certificates can be requested via vault's HTTP API like:

```bash
curl \
    --header "X-Vault-Token: $VAULT_TOKEN" \
    --request "POST" \
    --data '{ "common_name": "<cert_common_name>", "ttl": "<validity_period>" }' \
    $VAULT_ADDR/v1/pki_int/issue/cert-req
```

* The web server vm - `web01` will have:
  * Installed and running nginx server. Login to the server - `vagrant ssh web01`
  * A script that will request a certificate from Vault and enable a nginx site with it in `/vagrant/request_vault_certificate.sh`. The certificate CN will be `test.my-domain.com`. Vault will also provide the public certificate of the intermediate CA so that the server can present the chain to its clients.
  * The guest's `port 443` is mapped to the host's `port 4443` so the site is accessible form the host as well. The certificate will not be trusted unless Vault's Root CA's public certificate is imported on the guest.

* The web client vm - `client01` will have:
  * Vault's Root CA public certificate installed in the trusted CAs store.
  * A DNS entry for `test.my-domain.com` in `/etc/hosts` so that HTTP requests with the correct host can be made to the web server from it.

This way the web client can be used to make requests to the web server and verify that the leaf certificate issued by Vault is working.

`curl -v https://test.my-domain.com`