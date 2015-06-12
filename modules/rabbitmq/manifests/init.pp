# 
# This module manages rabbitmq
# 
# The config for rabbitmq requires a public/private key plus cacert file.


class rabbitmq {
  include apt

  package { 'rabbitmq':
    name => 'rabbitmq-server',
    ensure => installed,
    require => [
      File['/etc/apt/sources.list.d/rabbitmq.list'],
    ],
  }
  
  apt::key { '056E8E56':
    ensure => present,
    apt_key_url => 'https://www.rabbitmq.com/rabbitmq-signing-key-public.asc',
    before => [ File['/etc/apt/sources.list.d/rabbitmq.list'] ],
  }

  exec { 'enable-management':
   command => '/usr/sbin/rabbitmq-plugins enable rabbitmq_management',
   unless => '/usr/sbin/rabbitmq-plugins  list -e | grep rabbitmq_management > /dev/null',
   require => [ Service['rabbitmq'] ],
  }
  
  file { '/etc/rabbitmq/rabbitmq.config':
    owner => root,
    group => root,
    mode => 0644,
    source => 'puppet:///modules/rabbitmq/rabbitmq.config',
    notify => [ Service['rabbitmq'] ],
    require => [ Package['rabbitmq'] ],
  }
  
  file { '/etc/rabbitmq/rabbitmq-env.conf':
    owner => root,
    group => root,
    mode => 0644,
    source => 'puppet:///modules/rabbitmq/default',
    notify => [ Service['rabbitmq'] ],
    require => [ Package['rabbitmq'] ],
  }
  
  file { '/etc/apt/sources.list.d/rabbitmq.list':
    owner => root,
    group => root,
    mode => 0644,
    source => 'puppet:///modules/rabbitmq/rabbitmq.list',
    notify => [ Exec['apt-update'] ],
  }

  file { '/etc/rabbitmq/cert.pem':
    owner => rabbitmq,
    group => rabbitmq,
    mode => 0640,
    require => [ Package['rabbitmq'] ],
  }

  file { '/etc/rabbitmq/key.pem':
    owner => rabbitmq,
    group => rabbitmq,
    mode => 0640,
    require => [ Package['rabbitmq'] ],
  }

  file { '/etc/rabbitmq/cacert.pem':
    owner => rabbitmq,
    group => rabbitmq,
    mode => 0640,
    require => [ Package['rabbitmq'] ],
  }

  
  service { 'rabbitmq':
    name => 'rabbitmq-server',
    ensure => running,
    require => [ Package['rabbitmq'] ],
  }


}
