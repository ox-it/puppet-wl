class xtrabackup {

	$key_id = "1C4CBDCDCD2EFD2A"
	$apt_key_file = "/etc/apt/trusted.gpg.d/percona.gpg"

	package { 'gnupg':
		ensure => installed,
	}
	
	exec { 'gpg import percona':
		command => "gpg --keyserver  hkp://keys.gnupg.net --recv-keys ${key_id}",
		path => '/bin:/usr/bin',
		require => Package['gnupg'],
	}
	
	exec { 'apt-key add percona':
		command => "gpg -a --export ${key_id} | apt-key --keyring ${apt_key_file} add -",
		path => '/bin:/usr/bin',
		creates => $apt_key_file,
		require => Exec['gpg import percona'],
	}
	
	file { '/etc/apt/sources.list.d/xtrabackup.list':
		source => 'puppet:///modules/xtrabackup/xtrabackup.list',
		owner => root,
		group => root,
		mode => 0644,
		notify => Exec['apt-get update'],
		require => Exec['apt-key add percona'],
	}
	
	exec { 'apt-get update':
		command => '/usr/bin/apt-get update',
		refreshonly => true,
		require => Exec['apt-key add percona'],
	}
	
	package { 'percona-xtrabackup':
		ensure => installed,
		require => File['/etc/apt/sources.list.d/xtrabackup.list'],
	}
}