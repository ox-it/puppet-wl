# The Jira Service, frontended by Apache
class svc_jenkins (
    $hostname_virtual,
    $listen = '*',
    $http_port = 8080,
    $ajp_port = -1,
    $hostname_alts,
    ){

    include jenkins
    include apache2


    # The Apache frontend.
    file { "/etc/apache2/sites-available/jenkins":
        content => template('svc_jenkins/apache/jenkins.erb'),
        owner => root,
        group => root,
        mode => 0644,
        require => Package["apache2"],
    }

    file { "/etc/default/jenkins":
        content => template('svc_jenkins/jenkins.erb'),
        owner => root,
        group => root,
        mode => 0644,
        require => Class["jenkins"],
    }

    ssl::cert { "${hostname_virtual}":
        alts => $hostname_alts,
        # These should really be passed in as they are specific to the deployment
        public => "puppet:///modules/svc_jenkins/ssl/jenkins.oucs.ox.ac.uk.crt",
        chain => "puppet:///modules/svc_jenkins/ssl/jenkins.oucs.ox.ac.uk.chn",
    }

    apache2::site { "jenkins": 
        require => [
            File["/etc/apache2/sites-available/jenkins"],
            File["/etc/ssl/certs/${hostname_virtual}.crt"],
            File["/etc/ssl/private/${hostname_virtual}.key"],
            File["/etc/ssl/chain/${hostname_virtual}.pem"],
            Class["jenkins"],
        ]
    }

    # Remove the default apache site
    apache2::site { "000-default":
        ensure => absent,
    }

    apache2::module { "proxy_http":
        ensure => "present",
    }

    apache2::module { "ssl":
        ensure => "present",
        require => File["/etc/apache2/mods-available/ssl.conf"],
    }
        
    apache2::module { "rewrite":
        ensure => "present",
    }
        
}

