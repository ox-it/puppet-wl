class jenkins () {

    $apt_key_file = "/etc/apt/trusted.gpg.d/jenkins.gpg"
    $apt_key_url = "http://pkg.jenkins-ci.org/debian/jenkins-ci.org.key"
   
   file {'/etc/apt/sources.list.d/jenkins.list':
        source => 'puppet:///modules/jenkins/jenkins.list',
        owner => root,
        group => root,
        mode => 0644,
        notify => Exec['apt-get update'],
    }

    exec { 'apt-get update':
        command => '/usr/bin/apt-get update',
        refreshonly => true,
        require => Exec['apt-key add jenkins'],
    }


    exec { 'apt-key add jenkins':
        command => "wget -q -O - ${apt_key_url} | apt-key --keyring ${apt_key_file} add -",
        path => '/bin:/usr/bin',
        creates => $apt_key,
        require => Package['wget'],
    }

    package { 'wget':
        ensure => installed,
    }

    package { 'jenkins': 
        ensure => installed,
        require => [
            File['/etc/apt/sources.list.d/jenkins.list'],
            Exec['apt-get update'],
            Package['openjdk-6-jdk'],
        ],
    }

    package { 'openjdk-6-jdk':
        ensure => installed,
        require => Exec['apt-get update'],
    }

    service { 'jenkins':
        ensure => running,
        require => Package['jenkins'],
    }

}
