# Your nodes go here
node default {
  include ssh
  include users
}

node 'chedder' inherits default {
  include serial
}

# Node which runs our copy of nexus
node 'feta' inherits default {
  include serial
  include kerberos
  include nexus
  class { 'tsm':
    server_name       => 'OX_HFS_B4',
    server_address    => 'dsmb4.ox.ac.uk',
    server_port       => '2600',
    node_name         => 'feta.oucs',
    scheduler_enabled => 1,
  }
}

# Bits and bobs node.
node 'sole' inherits default {
  include serial
  include kerberos
}
