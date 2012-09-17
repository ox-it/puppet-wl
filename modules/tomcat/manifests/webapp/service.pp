# This defines the service (startup scripts and config)
define tomcat::webapp::service (
	$username,
	$description = $title,
	$webapp_base = "/srv",
	$java_opts = "-Djava.awt.headless=true -Xmx128m -XX:+UseConcMarkSweepGC",
	$max_number_open_files = undef
) {
	# We just copy the standard tomcat one.
	file { "/etc/init.d/${username}":
			ensure => file,
			owner => root,
			group => root,
			mode => 0755,
			source => "/etc/init.d/tomcat6",
			require => Tomcat::Webapp::Tomcat[$username]
	}
	
	file { "/etc/default/${username}":
			ensure => file,
			owner => root,
			group => root,
			mode => 0755,
			content => template('tomcat/service/default.erb'),
	}
	
	service { $username:
			ensure => running,
			enable => true,
			require => [
				File["/etc/init.d/${username}"],
				File["/etc/default/${username}"]
			],
			subscribe => [
				File["${webapp_base}/${username}/tomcat/conf/server.xml"],
			],
	}
}