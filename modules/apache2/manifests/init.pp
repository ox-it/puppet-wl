# Stolen from http://projects.puppetlabs.com/projects/1/wiki/Debian_Apache2_Recipe_Patterns
class apache2 {
  $apache2_sites = "/etc/apache2/sites"
  $apache2_mods = "/etc/apache2/mods"


   # Define an apache2 site. Place all site configs into
   # /etc/apache2/sites-available and en-/disable them with this type.
   #
   # You can add a custom require (string) if the site depends on packages
   # that aren't part of the default apache2 package. Because of the
   # package dependencies, apache2 will automagically be included.
   define site ( $ensure = 'present' ) {
      case $ensure {
         'present' : {
            exec { "/usr/sbin/a2ensite $name":
               unless => "/bin/readlink -e ${apache2::apache2_sites}-enabled/$name",
               notify => Exec["reload-apache2"],
               require => Package['apache2'],
            }
         }
         'absent' : {
            exec { "/usr/sbin/a2dissite $name":
               onlyif => "/bin/readlink -e ${apache2::apache2_sites}-enabled/$name",
               notify => Exec["reload-apache2"],
               require => Package['apache2'],
            }
         }
         default: { err ( "Unknown ensure value: '$ensure'" ) }
      }
   }

   # Define an apache2 module. Debian packages place the module config
   # into /etc/apache2/mods-available.
   #
   # You can add a custom require (string) if the module depends on 
   # packages that aren't part of the default apache2 package. Because of 
   # the package dependencies, apache2 will automagically be included.
   define module ( $ensure = 'present' ) {
      case $ensure {
         'present' : {
            exec { "/usr/sbin/a2enmod $name":
               unless => "/bin/readlink -e ${apache2::apache2_mods}-enabled/${name}.load",
               notify => Exec["force-reload-apache2"],
               require => Package['apache2'],
            }
         }
         'absent': {
            exec { "/usr/sbin/a2dismod $name":
               onlyif => "/bin/readlink -e ${apache2::apache2_mods}-enabled/${name}.load",
               notify => Exec["force-reload-apache2"],
               require => Package['apache2'],
            }
         }
         default: { err ( "Unknown ensure value: '$ensure'" ) }
      }
   }

   # Notify this when apache needs a reload. This is only needed when
   # sites are added or removed, since a full restart then would be
   # a waste of time. When the module-config changes, a force-reload is
   # needed.
   exec { "reload-apache2":
      command => "/etc/init.d/apache2 reload",
      refreshonly => true,
   }

   exec { "force-reload-apache2":
      command => "/etc/init.d/apache2 force-reload",
      refreshonly => true,
   }

   # Custom ssl.conf to disable SSLv3
   file { "/etc/apache2/mods-available/ssl.conf":
      source => "puppet:///modules/apache2/ssl.conf",
      mode => 644,
      owner => root,
      group => root,
      notify => Exec["force-reload-apache2"],
      require => Package["apache2"],
   }

   # We want to make sure that Apache2 is running.
   service { "apache2":
      ensure => running,
      hasstatus => true,
      hasrestart => true,
      require => Package["apache2"],
   }
   package { "apache2":
      ensure => present,
   }
}
