# Your nodes go here
node default {
  include ssh
  include users
  include serial
  include kerberos
  include ssmtp
  Exec { path => "/usr/bin:/usr/sbin/:/bin:/sbin" }

  # Make sure we don't have puppet listening/running as it is by default in 14.04
  service { 'puppet': 
    ensure => 'stopped',
  }
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

# Node which runs edam.oucs.ox.ac.uk
node 'edam' inherits default {
    class{ 'svc_logstash':
      hostname_virtual => 'edam.oucs.ox.ac.uk',
    }
    class { 'tsm':
        server_name       => 'OX_HFS_B2',
        server_address    => 'dsmb2.ox.ac.uk',
        server_port       => '2500',
        node_name         => 'edam.oucs',
        scheduler_enabled => 1,
    }
}

# Node which runs jenkins.oucs.ox.ac.uk
node 'chedder' inherits default {
    class { 'svc_jenkins':
        hostname_virtual => 'jenkins.oucs.ox.ac.uk',
        hostname_alts => ['jenkins.it.ox.ac.uk'],
    }
    class { 'tsm':
        server_name       => 'OX_HFS_B2',
        server_address    => 'dsmb2.ox.ac.uk',
        server_port       => '2500',
        node_name         => 'chedder.oucs',
        scheduler_enabled => 1,
    }
}


# Node which runs jira.oucs.ox.ac.uk
node 'ricotta' inherits default {
    class { 'svc_jira':
        hostname_virtual => 'jira.oucs.ox.ac.uk',
        hostname_alts => ['jira.it.ox.ac.uk'],
    }
    class { 'tsm':
        server_name       => 'OX_HFS_B14',
        server_address    => 'dsmb14.ox.ac.uk',
        server_port       => '2800',
        node_name         => 'ricotta.it',
        scheduler_enabled => 1,
    }
}

# Node which does VSO builds
node 'perch' inherits default {
}

# Bits and bobs node.
node 'sole' inherits default {
}

# This node runs git-sync to push changes in the Sakai SVN to github.
node 'swiss' inherits default {
    include git-sync
}
