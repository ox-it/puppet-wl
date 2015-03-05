class svc_logstash (
    $hostname_virtual,
    $listen = '*',
    $es_port = "9200",
  ){

  include apache2
  include secrets
  
  # This is the password used to connect logstash to rabbitmq
  # It shouldn't be used for client connections to rabbitmq
  $rabbitmq_username = "logstash"
  $rabbitmq_password = sha1("${fqdn}${secrets::secret}rabbitmq")

  exec {'ifup lo:2':
    command => '/sbin/ifup lo:2',
    refreshonly => true,
  }
    
  exec {'ifup lo:3':
    command => '/sbin/ifup lo:3',
    refreshonly => true,
  }
    

  file {'/etc/network/interfaces.d/lo2.cfg':
    owner => root,
    group => root,
    mode => 0644,
    source => 'puppet:///modules/svc_logstash/lo2.cfg',
    notify => Exec['ifup lo:2'],
  }

  file {'/etc/network/interfaces.d/lo3.cfg':
    owner => root,
    group => root,
    mode => 0644,
    source => 'puppet:///modules/svc_logstash/lo3.cfg',
    notify => Exec['ifup lo:3'],
  }


  host {'logstash':
    ip => '127.0.0.2',
  }

  host {'elasticsearch':
   ip => '127.0.0.3',
  }

  

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

  apache2::module { "ssl":
    ensure => "present",
    # Our custom SSL config
    require => File["/etc/apache2/mods-available/ssl.conf"],
  } 
  
#  apache2::module { "webauth":
#    ensure => "present",
#    require => Package["webauth"],
#  } ->
#
#  package { 'webauth':
#    name => "libapache2-webauth",
#    ensure => "present"
#  }

  class { 'rabbitmq':
  } ->

  rabbitmq::user { "$rabbitmq_username": 
    password => $rabbitmq_password
  } ->

  class { 'elasticsearch':
  } ->

  elasticsearch::instance { 'logstash':
    config => {
      'network.host' => 'elasticsearch'
    },
  } ->

  class {'logstash': 
    java_install => true,
  }

  logstash::configfile { 'indexer':
    content => template('svc_logstash/logstash/indexer.erb'),
  }

}
