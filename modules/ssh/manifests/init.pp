# Manage our ssh server

class ssh {
  package { 'openssh-server':
    ensure => present,
     before => File['/etc/ssh/sshd_config'],
  }

  file { '/etc/ssh/sshd_config':
    ensure => file,
    mode => 600,
    source => 'puppet:///modules/ssh/sshd_config',
  }

  service { 'sshd':
     ensure => running,
     enable => true,
     hasrestart => true,
     hasstatus => true,
     subscribe => File['/etc/ssh/sshd_config'],
  }
}
