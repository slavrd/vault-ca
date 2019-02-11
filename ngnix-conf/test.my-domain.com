server {
       listen 443 ssl;
        ssl_certificate     /etc/ssl/certs/vault_certificate.crt;
        ssl_certificate_key /etc/ssl/private/vault_certificate.key;

       server_name test.my-domain.com;

       root /vagrant/www;
       index index.html;

       location / {
               try_files $uri $uri/ =404;
       }
}