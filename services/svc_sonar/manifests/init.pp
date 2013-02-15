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

    $jenkins_password = file("/etc/mysql-jenkins-secret")
    exec { "create-mysql-user-jenkins" :
        command =>  "mysql -u root -e \"CREATE USER 'jenkins'@'%' IDENTIFIED BY '${jenkins_password}';\"",
        unless => "mysql -u root -N -r -s -e 'SELECT DISTINCT user FROM mysql.user' | grep -q '^jenkins\$'",
        require => Class["mysql"],
    }->
    exec { "grant-mysqldb-jenkins" :
        command => "mysql -u root -e \"GRANT ALL ON ${dbname}.* TO 'jenkins'@'%';\"",
        unless => "mysql -u root -s -N -r -e \"SHOW GRANTS FOR 'jenkins'@'%';\" | grep -q '${dbname}'",
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
