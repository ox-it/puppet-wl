# Class: jira
#
# This module manages jira
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
class jira7 (
	$user = "jira",	
	$database_name = "jira",
	$database_type = "postgres72",
	$database_schema = "public",
	$database_driver = "org.postgresql.Driver",
	$database_driver_jar = "postgresql-9.1-902.jdbc4.jar",
	$database_driver_source = "puppet:///modules/jira/db/postgresql-9.1-902.jdbc4.jar",
	$database_url = "jdbc:postgresql://localhost/jira",
	$database_user = "jira",
	$database_pass = "jira",
	$version = "7.1.0",
    $http = true,
    $ajp = true,
){
	
# configuration
	$jira_build = "atlassian-jira-software-${version}-jira-${version}-x64.bin" 
	$installer = "${jira_build}"
	$download_dir = "/tmp"
	$downloaded_installer = "${download_dir}/${installer}"
	$installer_response = "${download_dir}/response.varfile"
	$download_url = "https://www.atlassian.com/software/jira/downloads/binary/${jira_build}"
	$jira_dir = "/opt/atlassian/jira"
	$jira_home = "/var/atlassian/application-data/jira"
	
	# download the installer
	exec { "download-jira":
		command => "/usr/bin/wget -O ${downloaded_installer} ${download_url}",
		creates => $downloaded_installer,
		timeout => 1200,	
	}
	
	file { "installer-response" :
		path => "${installer_response}",
		ensure => file,
		content => template("jira7/response.varfile"),
	}
	
	file { $downloaded_installer :
		require => Exec["download-jira"],
		mode => 755,
		ensure => file,
	}
	
	exec { "install-jira":
		command => "$downloaded_installer -q -varfile response.varfile",
		cwd => $download_dir,
		creates => "${jira_dir}",
		timeout => 1200,
		require => [
			File[$downloaded_installer],
			File[installer-response],
			],
	}

	
	file { "dbconfig.xml" :
		path => "${jira_home}/dbconfig.xml",
		ensure => present,
		content => template("jira7/dbconfig.xml.erb"),
		require => Exec["install-jira"],
		owner => root,
		group => $user,
		mode => 640,
	}
	
	file { "server.xml" :
		path => "${jira_dir}/conf/server.xml",
		ensure => present,
		content => template("jira7/server.xml.erb"),
		require => Exec["install-jira"],
		owner => root,
		mode => 644,
	}
	
	# the database driver jar
	file { 'jira-db-driver':
		path => "${jira_dir}/lib/${database_driver_jar}", 
		source => $database_driver_source,
		ensure => file,
		owner => $user,
		group => $user,
		require => [
			Exec["install-jira"]
		]
	}   

}
