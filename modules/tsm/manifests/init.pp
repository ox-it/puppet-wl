# Does HFS/TSM backup
# After setup you still need to set the password with:
# dsmc set password
# For working out the ports look at
# http://www.oucs.ox.ac.uk/hfs/help/firewall.xml
# domain is the list of mount points to backup  (ALL-LOCAL is nice option)

class tsm ($server_name, $server_address, $server_port,
    $node_name, $password = '', $domain = '/', $scheduler_enabled = 1){

  $repo_package = "oucs-hfs-repo"
  $repo_url = "http://downloads.hfs.ox.ac.uk/repo/apt/pool/ox-hfs-repo_1.3.0-2_all.deb"
  $repo_file = "${repo_package}.deb"

  if $scheduler_enabled == 1 {
    service { 'tsm-scheduler': 
      ensure => running,
      enable => true,
    }
  } else {
    service { 'tsm-scheduler': 
      ensure => stopped,
      enable => false,
    }
  }

  
  package { 'tsm-client-base':
    ensure => installed,
    require => Exec['install-hfs-repo'],
  }

  exec { 'install-hfs-repo':
    cwd => "/tmp",
    # -C - continue where we left off
    # -L follow redirects
    command => "/usr/bin/curl -C - -L -o ${repo_file} ${repo_url} && dpkg -i /tmp/${repo_file} && apt-get update",
    unless => "/usr/bin/dpkg -l ${repo_package}"
  }

    file { "/opt/tivoli/tsm/client/ba/bin/dsm.opt":
        ensure  => present,
        content => template("tsm/dsm.opt.erb"),
        owner   => root,
        group   => root,
        mode    => 0644,
        require => Package["tsm-client-base"],
    }

    file { "/opt/tivoli/tsm/client/ba/bin/dsm.sys":
        ensure  => present,
        content => template("tsm/dsm.sys.erb"),
        owner   => root,
        group   => root,
        mode    => 0644,
        require => Package["tsm-client-base"],
    }

    file { "/opt/tivoli/tsm/client/ba/bin/dsmsched.rc":
        ensure  => present,
        content => template("tsm/dsmsched.rc.erb"),
        owner   => root,
        group   => root,
        mode    => 0644,
        require => Package["tsm-client-base"],
	notify  => Service["tsm-scheduler"],
    }
    
    # Logrotate for the logfiles
    file { "/etc/logrotate.d/tsm":
    	ensure => file,
    	source => 'puppet:///modules/tsm/tsm.logrotate',
    	owner => root,
    	group => root,
    	mode => 0644,
    }



}
