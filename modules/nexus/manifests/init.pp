# Install the nexus repository manager.
class nexus {
  
  include apache2

  $maven_repo_ip = "_default_" # Or $ipaddress
  $version = "2.1.2"
  $download = "nexus-${version}.war"
  $url = "http://www.sonatype.org/downloads/nexus-${version}.war"
  $install_dir = "/var/lib/nexus"
  $final = "/var/lib/tomcat7/webapps/${download}" # Keep the version as we're creating a custom context.xml
  $nexuswork = "${install_dir}/sonatype-work"
  $apache2_mods = "/etc/apache2/mods"


  package { 'tomcat7' : 
    ensure => installed,
  }

  # Disable the existing services
  apache2::site { ['000-default', 'default-ssl']:
    ensure => 'absent',
  }

  apache2::site { ['maven-repo']:
    ensure => 'present',
    require => File['/etc/apache2/sites-available/maven-repo'],
  }

  apache2::module { ['proxy', 'proxy_ajp', 'ssl']:
     ensure => 'present';
  }

  file { '/etc/apache2/sites-available/maven-repo':
    content => template('nexus/maven-repo.erb'),
    require => [ File['/etc/ssl/certs/utn-ca-chain.crt.pem', '/etc/ssl/certs/maven-repo.oucs.ox.ac.uk.crt'], Package['apache2'] ],
  }
  
  file { '/etc/ssl/certs/utn-ca-chain.crt.pem':
    source => 'puppet:///modules/nexus/utn-ca-chain.crt.pem',
    owner => root,
    group => root,
    mode => 644,
  }

  file { '/etc/ssl/certs/maven-repo.oucs.ox.ac.uk.crt':
     source => 'puppet:///modules/nexus/maven-repo.oucs.ox.ac.uk.crt',
     owner => root,
     group => root,
     mode => 644,
   }

  service { 'tomcat7':
    require => Package['tomcat7'],
    subscribe => [ File['/etc/tomcat7/server.xml'], File['/etc/default/tomcat7'] ],
  }


  # Needed for setting plexis home in the system properties args
  file { "/etc/default/tomcat7": 
    content => template('nexus/tomcat7.erb'),
    mode => '644',
    owner => 'root',
    group => 'root',
    backup => '.backup',
  }
 
  file { "${install_dir}": 
    ensure => directory,
    owner => tomcat7,
    mode => 644,
  }
 
  # We have to have the WAR expanded and todo that it must be in the webapps folder
  # and we want to set the context to ROOT but leave the filename as it is.
  # Leaving the filename makes upgrade/downgrade easier
  file { '/etc/tomcat7/server.xml': 
    content => template('nexus/server.xml.erb'),
    owner => root,
    mode => 644,
    require => Package['tomcat7'],
  }
  
  file { "${final}": 
    require => [ Exec['install-nexus'], File ["${install_dir}"] ],
    owner => root,
    mode => 644,
  }


  file { "${nexuswork}":
    owner => 'tomcat7',
    group => 'tomcat7',
    ensure => directory,
    mode => 644,
  }

  exec { 'install-nexus':
    cwd => "/tmp",
    require => Package['tomcat7'],
    # -C - continue where we left off
    # -L follow redirects
    command => "/usr/bin/curl -C - -L -o ${download} ${url} && /bin/cp /tmp/${download} ${final}",
    creates => "${final}",
  }
}
