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
