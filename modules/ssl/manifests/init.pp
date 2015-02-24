class ssl {

  define cert ( $alts ) {
    file { "/etc/ssl/${name}.cnf":
        content => template('ssl/cert.erb'),
        owner => root,
        group => root,
        mode => 0644,
    }

    file { "/etc/ssl/certs/${name}.crt":
        owner => root,
        group => root,
        mode => 0644,
    }

    file { "/etc/ssl/private/${name}.key":
        owner => root,
        group => root,
        mode => 0640,
    }
  }

}
