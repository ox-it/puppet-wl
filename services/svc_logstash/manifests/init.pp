class svc_logstash (
    $hostname_virtual,
    $listen = '*',
    $es_port = "9200",
    $webauth = "present",
  ){

  include apache2
  include secrets
  
  # This is the password used to connect logstash to rabbitmq
  # It shouldn't be used for client connections to rabbitmq
  $rabbitmq_username = "logstash"
  $rabbitmq_password = sha1("${fqdn}${secrets::secret}rabbitmq")

  exec {'ifup logstash':
    command => '/sbin/ifup lo:2',
    refreshonly => true,
  }
    
  exec {'ifup elasticsearch':
    command => '/sbin/ifup lo:3',
    refreshonly => true,
  }
    
  exec {'ifup kibana':
    command => '/sbin/ifup lo:4',
    refreshonly => true,
  }
    

  file {'/etc/network/interfaces.d/lo2.cfg':
    owner => root,
    group => root,
    mode => 0644,
    source => 'puppet:///modules/svc_logstash/lo2.cfg',
    notify => Exec['ifup logstash'],
  }

  file {'/etc/network/interfaces.d/lo3.cfg':
    owner => root,
    group => root,
    mode => 0644,
    source => 'puppet:///modules/svc_logstash/lo3.cfg',
    notify => Exec['ifup elasticsearch'],
  }

  file {'/etc/network/interfaces.d/lo4.cfg':
    owner => root,
    group => root,
    mode => 0644,
    source => 'puppet:///modules/svc_logstash/lo4.cfg',
    notify => Exec['ifup kibana'],
  }


  host {'logstash':
    ip => '127.0.0.2',
  }

  host {'elasticsearch':
   ip => '127.0.0.3',
  }

  host {'kibana':
   ip => '127.0.0.4',
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

  apache2::module {'rewrite':
    ensure => present,
  } ->

  apache2::module {'proxy':
    ensure => present,
  } ->

  apache2::module {'proxy_http':
    ensure => present,
  } ->

  apache2::module { "ssl":
    ensure => "present",
    # Our custom SSL config
    require => File["/etc/apache2/mods-available/ssl.conf"],
  } 

  apache2::module { "webauth":
    ensure => $webauth,
    require => Package["webauth"],
  } ->

  file {'/etc/apache2/sites-available/logstash.conf':
    content => template('svc_logstash/apache/logstash.erb'),
    owner => root,
    group => root,
    mode => 0644,
  } ->

  ssl::cert { $hostname_virtual:
    public => "puppet:///modules/svc_logstash/${hostname_virtual}.crt",
    chain => "puppet:///modules/svc_logstash/swiss-sign-chain.crt.pem",
    group => rabbitmq,
  } ->

  exec { "link-private":
    command => "/bin/ln /etc/ssl/private/${hostname_virtual}.key /etc/rabbitmq/key.pem",
    creates => "/etc/rabbitmq/key.pem",
  } ->

  exec { "link-public":
    command => "/bin/ln /etc/ssl/certs/${hostname_virtual}.crt /etc/rabbitmq/cert.pem",
    creates => "/etc/rabbitmq/cert.pem",
  } ->

  exec { "link-chain":
    command => "/bin/ln /etc/ssl/chain/${hostname_virtual}.pem /etc/rabbitmq/cacert.pem",
    creates => "/etc/rabbitmq/cacert.pem",
  } ->


  apache2::site {"logstash":
    ensure => present,
  }


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
    require => Exec['ifup elasticsearch'],
  } 

  class {'logstash': 
    java_install => true,
    require => Exec['ifup logstash'],
  }

  logstash::configfile { 'indexer':
    content => template('svc_logstash/logstash/indexer.erb'),
  }

  file {'/opt':
    ensure => 'directory',
    owner => root,
    group => root,
    mode => 0755,
  } ->
  
  file {'/opt/kibana':
    ensure => 'directory',
    owner => root,
    group => root,
    mode => 0755,
  } ->
  
  file {'/var/cache/puppet':
    ensure => 'directory',
    owner => root,
    group => root,
    mode => 0755,
  } ->

  exec {'download-kibana':
    command => '/usr/bin/curl -o /var/cache/puppet/kibana-4.0.1-linux-x64.tar.gz https://download.elasticsearch.org/kibana/kibana/kibana-4.0.1-linux-x64.tar.gz',
    creates => '/var/cache/puppet/kibana-4.0.1-linux-x64.tar.gz',
  } ~>

  exec {'unpack-kibana':
    command => '/bin/tar --strip-components=1 -zxf /var/cache/puppet/kibana-4.0.1-linux-x64.tar.gz',
    cwd => '/opt/kibana',
    refreshonly => true,
    notify => Service['kibana'],
  }
 
  group {'kibana':
    system => true,
    ensure => present,
  } ->

  user {'kibana':
    system => true,
    ensure => present,
    gid => 'kibana',
  } ->

  file {'/etc/init/kibana.conf':
    source => 'puppet:///modules/svc_logstash/kibana.conf',
    owner => root,
    group => root,
    mode => 0644,
  } ->

  file {'/var/log/kibana':
    ensure => 'directory',
    owner => 'kibana',
    group => 'adm',
    mode => 0755,
  } ->

  service {'kibana':
    ensure => running,
    require => [Exec['unpack-kibana'],Exec['ifup kibana']]
  }

  package { 'webauth':
    name => "libapache2-webauth",
    ensure => "present"
  }


}
