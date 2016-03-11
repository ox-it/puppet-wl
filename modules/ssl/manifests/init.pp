class ssl {

  define cert ( $alts = undef, $public = undef, $chain = undef, $user = root, $group = root) {
    file { "/etc/ssl/${name}.cnf":
        content => template('ssl/cert.erb'),
        owner => $user,
        group => $group,
        mode => 0644,
    }

    file { "/etc/ssl/certs/${name}.crt":
        owner => $user,
        group => $group,
        mode => 0644,
        source => $public,
    }

    file { "/etc/ssl/private/${name}.key":
        owner => $user,
        group => $group,
        mode => 0640,
    }

    file { "/etc/ssl/chain":
        ensure => "directory",
        owner => root,
        group => root,
        mode => 0755,
    } 

    file { "/etc/ssl/chain/${name}.pem":
      owner => root,
      group => root,
      mode => 0644,
      source => $chain,
      require => File["/etc/ssl/chain"],
    }
  }

}
