# Manage our ssh server
# Sets up restrictions in tcp wrappers

class ssh {

  # Make the staff subnet and IP range in case of DNS problems.
  $allowed-hosts = "LOCAL 129.67.100.0/255.255.252.0 .ox.ac.uk paper.bumph.org .eduroam.oxuni.org.uk"
  $denied-hosts = "ALL"

  # What's strange on debian is nothing seems to own /etc/hosts.{allow|deny}
  file { '/etc/hosts.allow':
    ensure => present,
    owner => root,
    # sed appends doesn't work on empty files
    replace => false,
    content => "# Default hosts.allow from puppet",
  }
  file { '/etc/hosts.deny':
    ensure => present,
    owner => root,
    # sed appends doesn't work on empty files
    replace => false,
    content => "# Default hosts.deny from puppet",
  }


  exec { 'allow-ssh':
    path => "/bin:/usr/bin",
    command => "sed -i -e '/^sshd:/d' -e '\$a\
sshd: ${allowed-hosts}
' /etc/hosts.allow",
    # -x Means we match the whole line so extra hosts can't be appended
    unless => "grep -qx 'sshd: ${allowed-hosts}' /etc/hosts.allow",
    require => File['/etc/hosts.allow'],
  }
  
  exec { 'deny-ssh':
    path => "/bin:/usr/bin",
    command => "sed -i -e '/^sshd:/d' -e '\$a\
sshd: ${denied-hosts}
' /etc/hosts.deny",
    # -x Means we match the whole line so extra hosts can't be appended
    unless => "grep -qx 'sshd: ${denied-hosts}' /etc/hosts.deny",
    require => File['/etc/hosts.deny'],
  }

  package { 'openssh-server':
    ensure => present,
    before => File['/etc/ssh/sshd_config'],
  }

  file { '/etc/ssh/sshd_config':
    ensure => file,
    mode => 600,
    owner => root,
    source => 'puppet:///modules/ssh/sshd_config',
  }

  service { 'ssh':
     ensure => running,
     enable => true,
     hasrestart => true,
     hasstatus => true,
     subscribe => File['/etc/ssh/sshd_config'],
  }
}
