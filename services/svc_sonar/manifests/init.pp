# The sonar Service, frontended by Apache
class svc_sonar {
    include mysql
    include secrets

    $app = 'sonar'

    $dbuser = "${app}user"
    $dbname = "${app}db"
    $dbpass = sha1("${fqdn}${secrets::root}${app}")

    # Setup the Mysql user and DB
    mysql::user { "$dbuser":
        username => "$dbuser",
        password => "$dbpass",
    }
    mysql::user { 'jenkins':
        username => 'jenkins',
        password => file("/etc/mysql-jenkins-secret"),
    }

    exec { "grant-mysqldb-jenkins" :
        command => "mysql -u root -e \"GRANT ALL ON ${dbname}.* TO 'jenkins'@'0.0.0.0';\"",
        unless => "mysql -u root -s -N -r -e \"SHOW GRANTS FOR 'jenkins'@'0.0.0.0';\" | grep -q '${dbname}'",
        path => ["/bin", "/usr/bin"],
		require => [Class["mysql"],Mysql::User['jenkins']],
    }

    mysql::db { "$dbname":
        name    => "$dbname",
        owner   => "$dbuser",
    }

    package { 'java7-runtime-headless':
        ensure => present,
    }

    # Setup Sonar
    class{ 'sonar':
        app_base => '/opt',
        database_user => "$dbuser",
        database_pass => "$dbpass",
        database_url  => "jdbc:mysql://localhost/${dbname}",

        require => [Mysql::Db[$dbname], Package['java7-runtime-headless']],
    }
}
