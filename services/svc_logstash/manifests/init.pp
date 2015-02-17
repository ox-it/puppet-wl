class svc_logstash {

  apt::key {'D88E42B4':
    ensure => present,
    apt_key_url => 'http://packages.elasticsearch.org/GPG-KEY-elasticsearch'
  } ->
  
  file {'/etc/apt/sources.list.d/logstash.list':
    owner => root,
    group => root,
    mode => 0644,
    source => 'puppet:///modules/svc_logstash/logstash.list',
    notify => [ Exec['apt-update'] ],
  } ->

  file {'/etc/apt/sources.list.d/elasticsearch.list':
    owner => root,
    group => root,
    mode => 0644,
    source => 'puppet:///modules/svc_logstash/elasticsearch.list',
    notify => [ Exec['apt-update'] ],
  } ->

  class { 'rabbitmq':
  } ->

  class { 'elasticsearch':
  } ->

  class {'logstash': 
    java_install => true,
  }

}
