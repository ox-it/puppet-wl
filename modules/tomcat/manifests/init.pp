# Class: tomcat
#
# This module manages Tomcat 6 and allows the creation of Tomcat user instances
class tomcat {
	class {'tomcat::packages': }
	class {'tomcat::services': 
		require => Class["tomcat::packages"]
	}
}

# Ok, so we copy /etc/default/tomcat to /etc/default/${user}
# copy /etc/init.d/tomcat6 /etc/init.d/${user}

# logs
# copy the tomcat bits from /var/lib/tomcat6

#common, server, shared, webapps

#conf - out own location.
#logs - /var/log/jira/ - need to create
#work - /var/cache/jira/  - need to create
