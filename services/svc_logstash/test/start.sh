#!/bin/bash

# Just sets up the puppet secret so we can generate passwords
if [ ! -f "/etc/puppet-secret" ] ; then 
  echo -n "secret" > /etc/puppet-secret
  chmod 600 /etc/puppet-secret
fi

# Need to generate a public/private key
# And make ourselves the CA
if [ ! -f /etc/rabbitmq/cert.pem -o ! -f /etc/rabbitmq/key.pem -o ! -f /etc/rabbitmq/cacert.pem ] ; then 
  mkdir -p /etc/rabbitmq
  openssl req -x509 -subj '/CN=localhost' -nodes -newkey rsa:2048 -keyout /etc/rabbitmq/key.pem -out /etc/rabbitmq/cert.pem -days 365
  cp /etc/rabbitmq/cert.pem /etc/rabbitmq/cacert.pem
fi
if [ ! -f /etc/ssl/certs/localhost.crt -o ! -f /etc/ssl/private/localhost.key ] ; then
  openssl req -x509 -subj '/CN=localhost' -nodes -newkey rsa:2048 -keyout /etc/ssl/private/localhost.key -out /etc/ssl/certs/localhost.crt -days 365
fi

if [ $(find /var/cache/apt -maxdepth 0 -mtime -24| wc -l) -eq 0 ]; then
  apt-get update
fi
exit 0
