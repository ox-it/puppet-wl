# Does HFS/TSM backup
# After setup you still need to set the password with:
# dsmc set password

class tsm ($server_name, $server_address, $server_port,
    $node_name, $password = '', $domain = '/'){

  $repo-package = "oucs-hfs-repo"
  $repo-url = "ftp://ftp.hfs.ox.ac.uk/repo/apt/deb/oucs-hfs-repo.deb"
  $repo-file = "${repo-package}.deb"

  
  package { 'tsm-client-base':
    ensure => installed,
    require => Exec['install-hfs-repo'],
  }

  exec { 'install-hfs-repo':
    cwd => "/tmp",
    # -C - continue where we left off
    # -L follow redirects
    command => "/usr/bin/curl -C - -L -o ${repo-file} ${repo-url} && dpkg -i /tmp/${repo-file} && apt-get update",
    unless => "/usr/bin/dpkg -l ${repo-package}"
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


}
