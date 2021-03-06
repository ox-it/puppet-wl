class users {
  
  $krb_realm = "OX.AC.UK"

  # Users who can login and setup their k5login.
  # We assume people will have accounts that match their SSO name.
  define krb-user ($user = $title, $name) {

      k5login { "/home/${user}/.k5login":
        ensure => present,
        principals => ["${user}@${users::krb_realm}", "${user}/root@${users::krb_realm}"],
        require => User[$user],
      }

      user { "${user}":
        home => "/home/${user}",
        shell => '/bin/bash',
        managehome => true, # Doesn't update users, but works for new
        ensure => present,
        comment => "${name}",
        groups => 'users', # Needed to allow ssh access
      }
  }

  # If we're adding people to a group make sure it exists.
  group { "users":
    ensure => present,
  }

  krb-user { 'buckett':
    name => 'Matthew Buckett',
  }

  # Disable Colin's account
  user { 'oucs0164':
    comment => 'Colin Hebert',
    shell => '/bin/false',
    password => '+',
  }

  krb-user { 'ouit0196':
    name => 'Nick Wilson',
  }

  user { "root":
    ensure => present,
    home => '/root',
  }
  
  k5login { '/root/.k5login':
    principals => ["buckett/root@${krb_realm}", "ouit0196/root@${krb_realm}"],
    require => User['root'],
  }

}
