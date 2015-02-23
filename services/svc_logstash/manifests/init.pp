class svc_logstash (
    $hostname_virtual,
    $listen = '*',
    $es_port = "9200",
  ){

  include apache2

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


  file {'/etc/apache2/sites-available/logstash':
    content => template('svc_logstash/apache/logstash.erb'),
    owner => root,
    group => root,
    mode => 0644,
    require => Package["apache2"], 
  } ->

  apache2::module { "webauth":
    ensure => "present",
  } ->

  apache2::modules { "ssl":
    ensure => "present",
    # Our custom SSL config
    require => File["/etc/apache2/mods-available/ssl.conf"],
  } ->

  class { 'rabbitmq':
  } ->

  class { 'elasticsearch':
    ensure => "present",
  } ->

  class {'logstash': 
    java_install => true,
  }

}
