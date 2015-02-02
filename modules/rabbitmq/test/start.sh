#!/bin/bash

# Just sets up the puppet secret so we can generate passwords
if [ ! -f "/etc/puppet-secret" ] ; then 
  echo -n "secret" > /etc/puppet-secret
  chmod 600 /etc/puppet-secret
fi

# Need to generate a public/private key
# And make ourselves the CA
mkdir -p /etc/rabbitmq
openssl req -x509 -subj '/CN=localhost' -nodes -newkey rsa:2048 -keyout /etc/rabbitmq/key.pem -out /etc/rabbitmq/cert.pem -days 365
cp /etc/rabbitmq/cert.pem /etc/rabbitmq/cacert.pem


if [ $(find /var/cache/apt -maxdepth 0 -mtime -24| wc -l) -eq 0 ]; then
  apt-get update
fi
exit 0
