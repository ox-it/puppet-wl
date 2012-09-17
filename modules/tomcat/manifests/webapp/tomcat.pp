# This creates a tomcat contains into which webapps can be deployed.

define tomcat::webapp::tomcat ($username,
	$number = 1,
	$server_host_config = "",
	$http = true,
	$ajp = true,
	$webapp_base = "/srv") {
	
	
	file {
		"${webapp_base}/${username}/tomcat" :
			ensure => directory,
			owner => $username,
			group => $username,
			mode => 0755,
			require => [Class["tomcat"], Tomcat::Webapp::User[$username]],
	}
	
	# The stuff outside /src
	file { "/var/log/${username}" :
		ensure => directory,
		owner => $username,
		group => adm,
		mode => 0750,
	}
	
	file { "/var/cache/${username}" :
		ensure => directory,
		owner => $username,
		group => adm,
		mode => 0750,
	}
	
	file { "/etc/${username}" :
			ensure => link,
			target => "${webapp_base}/${username}/tomcat/conf",
	}
	
	file {
		"${webapp_base}/${username}/tomcat/logs" :
			ensure => link,
			owner => $username,
			group => $username,
			mode => 0755,
			target => "/var/log/${username}",
	}
	file {
		"${webapp_base}/${username}/tomcat/work" :
			ensure => link,
			owner => $username,
			group => $username,
			mode => 0755,
			target => "/var/cache/${username}",
	}
	
	
	file {
		"${webapp_base}/${username}/tomcat/webapps" :
			ensure => directory,
			owner => $username,
			group => $username,
			mode => 0755,
	}
	
	# Need todo more.
	file {
		"${webapp_base}/${username}/tomcat/conf" :
			ensure => directory,
			owner => $username,
			group => $username,
			mode => 0755,
	}
	file {
		"${webapp_base}/${username}/tomcat/lib" :
			ensure => directory,
			owner => $username,
			group => $username,
			mode => 0755,
	}
	file {
		"${webapp_base}/${username}/tomcat/shared" :
			ensure => directory,
			owner => $username,
			group => $username,
			mode => 0755,
	}
	file {
		"${webapp_base}/${username}/tomcat/shared/classes" :
			ensure => directory,
			owner => $username,
			group => $username,
			mode => 0755,
	}
	file {
		"${webapp_base}/${username}/tomcat/conf/server.xml" :
			ensure => file,
			owner => $username,
			group => $username,
			mode => 0600, # We have passwords in here
			require => File["${webapp_base}/${username}/tomcat/conf"],
			content => template('tomcat/conf/server.xml.erb'),
	}
	file {
		"${webapp_base}/${username}/tomcat/conf/catalina.policy" :
			ensure => file,
			owner => $username,
			group => $username,
			mode => 0644,
			source => "puppet:///modules/tomcat/conf/catalina.policy",
			require => File["${webapp_base}/${username}/tomcat/conf"],
	}
	file {
		"${webapp_base}/${username}/tomcat/conf/policy.d" :
			ensure => directory,
			owner => $username,
			group => $username,
			mode => 755,
	}
	file {
		"${webapp_base}/${username}/tomcat/conf/policy.d/none.policy" :
			ensure => present,
			owner => $username,
			group => $username,
			mode => 0644,
			source => "puppet:///modules/tomcat/conf/policy.d/none.policy",
	}
	file {
		"${webapp_base}/${username}/tomcat/conf/catalina.properties" :
			ensure => file,
			owner => $username,
			group => $username,
			mode => 0644,
			source => "puppet:///modules/tomcat/conf/catalina.properties",
			require => File["${webapp_base}/${username}/tomcat/conf"],
	}
	file {
		"${webapp_base}/${username}/tomcat/conf/context.xml" :
			ensure => file,
			owner => $username,
			group => $username,
			mode => 0644,
			source => "puppet:///modules/tomcat/conf/context.xml",
			require => File["${webapp_base}/${username}/tomcat/conf"],
	}
	file {
		"${webapp_base}/${username}/tomcat/conf/logging.properties" :
			ensure => file,
			owner => $username,
			group => $username,
			mode => 0644,
			source => "puppet:///modules/tomcat/conf/logging.properties",
			require => File["${webapp_base}/${username}/tomcat/conf"],
	}
	file {
		"${webapp_base}/${username}/tomcat/conf/tomcat-users.xml" :
			ensure => file,
			owner => $username,
			group => $username,
			mode => 0644,
			source => "puppet:///modules/tomcat/conf/tomcat-users.xml",
			require => File["${webapp_base}/${username}/tomcat/conf"],
	}
	file {
		"${webapp_base}/${username}/tomcat/conf/web.xml" :
			ensure => file,
			owner => $username,
			group => $username,
			mode => 0644,
			source => "puppet:///modules/tomcat/conf/web.xml",
			require => File["${webapp_base}/${username}/tomcat/conf"],
	}
}