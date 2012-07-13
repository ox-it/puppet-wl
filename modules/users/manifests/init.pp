class users {
  
  $krb-realm = "OX.AC.UK"

  # Users who can login.
  define krb-user ($user = $title, $name) {

      k5login { "/home/${user}/.k5login":
        ensure => present,
        principals => ["${user}@${users::krb-realm}", "${user}/root@${users::krb-realm}"],
        require => User[$user],
      }

      user { "${user}":
        home => "/home/${user}",
        ensure => present,
        comment => "${name}",
	groups => 'users', # Needed to allow ssh access
      }
  }

  krb-user { 'buckett':
    name => 'Matthew Buckett',
  }

  user { "root":
    ensure => present,
    home => '/root',
  }
  
  k5login { '/root/.k5login':
    principals => ["buckett/root@${krb-realm}"],
    require => User['root'],
  }

}
