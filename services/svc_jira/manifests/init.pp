# The Jira Service, frontended by Apache
class svc_jira (
	$hostname_virtual,
	$listen = '*',
	$hostname_alts = undef,
	){
	include apt
    include mysql
    include tomcat
    include apache2
    include secrets

    # All these should be passed in.
    $context = "jira"
    $number = 0


    $dbpass = sha1("${fqdn}${secrets::secret}jirauser")
    $driver_url = "http://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-5.1.34.zip"

    # Setup the Mysql user and DB
    mysql::user { 'jirauser': 
        username => 'jirauser',
        password => $dbpass,
    }
    mysql::db { 'jiradb':
        name => 'jiradb63',
        owner => 'jirauser'
    }
    
     ssl::cert { "${hostname_virtual}":
        alts => $hostname_alts,
        public => "puppet:///modules/svc_jira/ssl/${hostname_virtual}.crt",
        chain => "puppet:///modules/svc_jira/ssl/utn-ca-chain.crt.pem",
        notify => Service["apache2"],
    }

    # download extra libraries needed by JIRA
    exec { "download-db-driver":
        command => "/usr/bin/wget -O /tmp/mysql-connector.zip ${driver_url}",
        creates => "/tmp/mysql-connector.zip",
        timeout => 1200,
    }

    # Location to cache the downloads of files.
    file { ["/var/cache/puppet", "/var/cache/puppet/jira"]:
        ensure => directory,
    }

    package { "unzip" :
        ensure => installed,
    }

    
    exec { "extract-db-driver":
        # The -j drops all folders, -o overwrite, and just extract the one file.
        command => "/usr/bin/unzip -j  -o -d /var/cache/puppet/jira /tmp/mysql-connector.zip *mysql-connector-java-5.1.34-bin.jar",
        creates =>"/var/cache/puppet/jira/mysql-connector-java-5.1.34-bin.jar",
        require => [
            Package["unzip"],
            File["/var/cache/puppet/jira"],
            Exec["download-db-driver"]
        ]
    }

    # The jira setup
    class { "jira": 
        user => "jira", #the system user that will own the JIRA Tomcat instance
        database_name => "jiradb63",
        database_type => "mysql",
        database_schema => "",
        database_driver => "com.mysql.jdbc.Driver",
        database_driver_jar => "mysql-connector-java-5.1.34-bin.jar",
        database_driver_source => "file:///var/cache/puppet/jira/mysql-connector-java-5.1.34-bin.jar",
        # Ends up in an XML file so needs to be encoded.
        database_url => "jdbc:mysql://localhost/jiradb63?useUnicode=true&amp;characterEncoding=UTF8&amp;sessionVariables=storage_engine=InnoDB",
        database_user => "jirauser",
        database_pass => $dbpass,
        number => $number, # the Tomcat http port will be 8280
        version => "6.3.10", # the JIRA version
        jira_jars_version => "6.3",
        contextroot => "jira",
        webapp_base => "/opt", # JIRA will be installed in /opt/jira
        http => false,
        require => [
                Mysql::Db['jiradb'],
                Class["tomcat"],
                Exec["extract-db-driver"]
        ]
    }
    
    # Log rotation
    file { "/etc/logrotate.d/jira":
        source => "puppet:///modules/svc_jira/logrotate/jira",
        owner => root,
        group => root,
        mode => 644,
    }
    
    # Backup cleanup
    file { "/etc/cron.daily/jira":
        source => "puppet:///modules/svc_jira/cron/jira",
        owner => root,
        group => root,
        mode => 755,
    }

    # The Apache frontend.
    file { "/etc/apache2/sites-available/jira.conf":
        content => template('svc_jira/apache/jira.conf.erb'),
        owner => root,
        group => root,
        mode => 0644,
        require => Package["apache2"],
    }
    
    apache2::site {"000-default":
    	ensure => "absent",
    }

    apache2::site { "jira": 
        require => [
        	Ssl::Cert["${hostname_virtual}"],
            File["/etc/apache2/sites-available/jira.conf"],
            Class["jira"],
        ]
    }

    apache2::module { "rewrite":
        ensure => "present",
    }

    apache2::module { "proxy_ajp":
        ensure => "present",
    }

    apache2::module { "ssl":
        ensure => "present",
        require => [
            File["/etc/apache2/mods-available/ssl.conf"],
        ]
    }
        
}

