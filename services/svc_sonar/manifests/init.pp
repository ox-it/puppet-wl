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
    }->
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
