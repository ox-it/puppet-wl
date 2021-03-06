# Manage our ssh server
# Sets up restrictions in tcp wrappers
class ssh {

  # Make the staff subnet and IP range in case of DNS problems.
  # 212.159.26.200 is my home IP
  $allowed_hosts = "LOCAL 129.67.100.0/255.255.252.0 .ox.ac.uk paper.bumph.org .eduroam.oxuni.org.uk 212.159.26.200"
  $denied_hosts = "ALL"

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
    # We have to use multiple commands as if the delete removes the last line
    # the append then fails to work.
    command => "sed -i -e '/^sshd:/d' /etc/hosts.allow && sed -i -e '\$a\
sshd: ${allowed_hosts}
' /etc/hosts.allow",
    # -x Means we match the whole line so extra hosts can't be appended
    unless => "grep -qx 'sshd: ${allowed_hosts}' /etc/hosts.allow",
    require => File['/etc/hosts.allow'],
  }
  
  exec { 'deny-ssh':
    path => "/bin:/usr/bin",
    # We have to use multiple commands as if the delete removes the last line
    # the append then fails to work.
    command => "sed -i -e '/^sshd:/d' /etc/hosts.deny && sed -i -e '\$a\
sshd: ${denied_hosts}
' /etc/hosts.deny",
    # -x Means we match the whole line so extra hosts can't be appended
    unless => "grep -qx 'sshd: ${denied_hosts}' /etc/hosts.deny",
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
