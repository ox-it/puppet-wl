include tomcat
include mysql
#include postgres
include secrets

package { 'openjdk-6-jdk':
	ensure => present,
  require  => Exec['apt-get update'],
}

package { 'unzip':
	ensure => present,
}

# Base image is out of date and otherwise 
exec { 'apt-get update':
        command => '/usr/bin/apt-get update',
}

$dbpass = sha1("${fqdn}${secrets::secret}jirauser")
$driver_url = "http://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-5.1.21.zip/from/http://cdn.mysql.com/"

mysql::user { 'jirauser': 
	username => 'jirauser',
	password => $dbpass,
}

mysql::db { 'jiradb':
	name => 'jiradb',
	owner => 'jirauser'
}

# download extra libraries needed by JIRA
	exec { "download-db-driver":
		command => "/usr/bin/wget -O /tmp/mysql-connector-java-5.1.21.zip ${driver_url}",
		creates => "/tmp/mysql-connector-java-5.1.21.zip",
		timeout => 1200,
	}

# Location to cache the downloads of files.
	file { ["/var/cache/puppet", "/var/cache/puppet/jira"]:
		ensure => directory,
	}

	
	exec { "extract-db-driver":
		# The -j drops all folders, -o overwrite, and just extract the one file.
		command => "/usr/bin/unzip -j  -o -d /var/cache/puppet/jira /tmp/mysql-connector-java-5.1.21.zip *mysql-connector-java-5.1.21-bin.jar",
		creates =>"/var/cache/puppet/jira/mysql-connector-java-5.1.21-bin.jar",
		require => [
			Package["unzip"],
			File["/var/cache/puppet/jira"],
			Exec["download-db-driver"]
		]
	}

class { "jira": 
	user => "jira", #the system user that will own the JIRA Tomcat instance
	database_name => "jiradb",
	database_type => "mysql",
	database_schema => "",
	database_driver => "com.mysql.jdbc.Driver",
	database_driver_jar => "mysql-connector-java-5.1.21-bin.jar",
	database_driver_source => "file:///var/cache/puppet/jira/mysql-connector-java-5.1.21-bin.jar",
	database_url => "jdbc:mysql://localhost/jiradb",
	database_user => "jirauser",
	database_pass => $dbpass,
	number => 2, # the Tomcat http port will be 8280
	version => "5.1.4", # the JIRA version
	jira_jars_version => "5.1",
	contextroot => "jira",
	webapp_base => "/opt", # JIRA will be installed in /opt/jira
	require => [
		Mysql::Db['jiradb'],
		Class["tomcat"],
		Exec["extract-db-driver"]
	]
}


class {"jira::plugin::subversion": }

jira::extra { "images": }
jira::extra { "images/oucslogo.png": }

