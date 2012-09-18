# Your nodes go here
node default {
  include ssh
  include users
  include serial
  include kerberos
  include ssmtp
}

node 'chedder' inherits default {
}

# Node which runs our copy of nexus
node 'feta' inherits default {
  include nexus
  class { 'tsm':
    server_name       => 'OX_HFS_B4',
    server_address    => 'dsmb4.ox.ac.uk',
    server_port       => '2600',
    node_name         => 'feta.oucs',
    scheduler_enabled => 1,
  }
}

# Node which runs jira.oucs.ox.ac.uk
node 'edam' inherits default {
    include svc_jira
}

# Bits and bobs node.
node 'sole' inherits default {
}
