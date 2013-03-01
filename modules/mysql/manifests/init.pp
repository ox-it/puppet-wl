# Class: mysql
#
# This module manages postgres
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
# [Remember: No empty lines between comments and class definition]
class mysql {
	package { 'mysql' :
			name => ['mysql-server', 'mysql-client'],
			ensure => present,
	}

	service { 'mysql' :
			ensure => running,
			enable => true,
			require => Package["mysql"],
	}
	
	# We do not want anyone looking at the backups
	file { '/var/backups/mysql' :
		ensure => "directory",
        owner => root,
        group => root,
        mode => 0700,
    }
	
	# Do daily backups of all databases
	file { '/etc/cron.daily/mysqlbackup' :
		source => 'puppet:///modules/mysql/mysqlbackup-cron',
        owner => root,
        group => root,
        mode => 0755,
        require => [
        	File['/var/backups/mysql'],
        	Package['mysql'],
        ],
    }
    
    file { '/etc/logrotate.d/mysqlbackup' :
    	source => 'puppet:///modules/mysql/mysqlbackup-logrotate',
        owner => root,
        group => root,
        mode => 0644,
        require => File['/var/backups/mysql'],
    }
}

