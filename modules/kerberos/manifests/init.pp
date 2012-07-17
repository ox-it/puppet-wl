# Configure kerberos for Oxford
class kerberos {
  
  package { 'krb5-user':
    ensure => installed,
  }

  # Need a machine principal
  file { '/etc/krb5.keytab':
    owner => root,
    mode => 600,
    require => Package['krb5-user'],
    ensure => file,
    noop => true,
  }
} 
