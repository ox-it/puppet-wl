# The Jira Service, frontended by Apache
class svc_jira {
    include mysql
    include tomcat
    include apache2
    include secrets

    $hostname_virtual = "jira.oucs.ox.ac.uk"
    $context = "jira"
    $number = 0


    $dbpass = sha1("${fqdn}${secrets::secret}jirauser")
    $driver_url = "http://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-5.1.21.zip/from/http://cdn.mysql.com/"

    # Setup the Mysql user and DB
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

    package { "unzip" :
        ensure => installed,
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

    # The jira setup
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
        number => $number, # the Tomcat http port will be 8280
        version => "5.1.4", # the JIRA version
        jira_jars_version => "5.1",
        contextroot => "jira",
        webapp_base => "/opt", # JIRA will be installed in /opt/jira
        http => false,
        require => [
                Mysql::Db['jiradb'],
                Class["tomcat"],
                Exec["extract-db-driver"]
        ]
    }

    class {"jira::plugin::subversion": }

    jira::extra { "images": }
    jira::extra { "images/oucslogo.png": }

    # The Apache frontend.
    file { "/etc/apache2/sites-available/jira":
        content => template('svc_jira/apache/jira.erb'),
        owner => root,
        group => root,
        mode => 0644,
        require => Package["apache2"],
    }

    file { "/etc/ssl/certs/${hostname_virtual}.crt":
        owner => root,
        group => root,
        mode => 0644,
    }

    file { "/etc/ssl/certs/utn-ca-chain.crt.pem":
        owner => root,
        group => root,
        mode => 0644,
        source => "puppet:///modules/svc_jira/ssl/utn-ca-chain.crt.pem",
    }

    file { "/etc/ssl/private/${hostname_virtual}.key":
        owner => root,
        group => root,
        mode => 0640,
    }

    apache2::site { "jira": 
        require => [
            File["/etc/apache2/sites-available/jira"],
            File["/etc/ssl/certs/${hostname_virtual}.crt"],
            File["/etc/ssl/private/${hostname_virtual}.key"],
            File["/etc/ssl/certs/utn-ca-chain.crt.pem"],
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
    }
        
}

