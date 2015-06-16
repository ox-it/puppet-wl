WebLearn Puppet Files
---------------------

These are the config files for the development services for WebLearn. 

There is another repository which contains all the secrets (keys/passwords).
These puppet files are designed to be used in a masterless setup where
each node has a copy of everything.

Running
-------

To run this on a node use:

    puppet apply --modulepath /etc/puppet/modules/:/etc/puppet/services/ /etc/puppet/manifests/site.pp 
to test a module on a node use:

   puppet apply --modulepath /etc/puppet/modules/:/etc/puppet/services/ -e "include users"

HFS
---

Currently you have to set the password for a TSM client in the web interface.
The puppet module just installs the software and configures it, no setting 
of the password is done. To set the password login to the client and run
`dsmc` you will get prompted to enter the password and then it will get saved
on the client.

TLS Certificates
----------------

The private key for all TLS certificates is kept in another repository.
Public keys and certificate chains can be kept in this repository. The ssl module
can be used to setup permissions and copy across files. It also creates
an openssl config file that can easily be used for generating CSRs.

RabbitMQ
--------

This currently only runs on 14.04 and not on 12.04 as the old Ubuntu version doesn't have a new enough version of Erlang to support SSL.

ElasticSearch, Logstash, Kibana
-------------------------------

These are all setup to run on thier own loopback interfaces, this makes choosing ports easy and sensible as well as allowing multicast.
However if you let them all run on IPv6 things break so both logstash and elasticsearch should be told to prefer IPv4 instead.
https://jira.spring.io/browse/SGF-28
