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
}

