class sonar (
    $user = 'sonar',
    $version = '3.4.1',
    $app_base = '/srv',

    $database_user = 'sonar',
    $database_pass = 'sonar',
    $database_url  = 'jdbc:h2:tcp://localhost:9092/sonar',) {

    $folder = "sonar-${version}"
    $package = "${folder}.zip"
    $source_url = "http://dist.sonar.codehaus.org/${package}"
    $install_dir = "$app_base/$user"
    $destination = "$install_dir/$package"

    package{ 'unzip':
        ensure => present,
    }

    user { "$user" :
        ensure => present,
        shell => '/bin/false',
    }->
    file { "$install_dir" :
        ensure => directory,
        owner => "$user",
        group => "$user",
        require => User["$user"];
    }

    exec { 'download-sonar':
        command => "/usr/bin/wget -O $destination $source_url",
        creates => "$destination",
        timeout => 1200,
        require => File["$install_dir"]
    }

    exec { 'unzip-sonar' :
        command => "unzip ${destination} -d ${install_dir}",
        unless  => "test -d ${install_dir}/${folder}",
        user    => "$user",
        require => [
            Exec['download-sonar'],
            Package['unzip'],
        ]
    }->
    file { "${install_dir}/${folder}/conf/sonar.properties":
        content => template('sonar/sonar/sonar.properties.erb'),
        owner => $user,
        group => $user,
        mode => 0644,
    }->
    exec { 'start-sonar' :
        command => "${install_dir}/${folder}/bin/linux-x86-64/sonar.sh start",
        user    => "$user",
        require => Exec['unzip-sonar']
    }
}
