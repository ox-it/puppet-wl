#!/bin/bash

# Just sets up the puppet secret so we can generate passwords
if [ ! -f "/etc/puppet-secret" ] ; then 
  echo -n "secret" > /etc/puppet-secret
  chmod 600 /etc/puppet-secret
fi
exit 0
