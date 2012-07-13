
# Nice simple smtp trasport 
class ssmtp {

  $mailhub = 'smtp.ox.ac.uk'

  # Email for admin
  $admin = 'buckett'

  # Domain to rewrite to.
  $domain = 'nexus.ox.ac.uk'

  file { '/etc/ssmtp/ssmtp.conf':
    owner => root,
    mode => 644,
    content => template('ssmtp/ssmtp.conf.erb'),
    require => Package['ssmtp'],
  }
  
  file { '/etc/ssmtp/revaliases':
    owner => root,
    mode => 644,
    content => template('ssmtp/revaliases.erb'),
    require => Package['ssmtp'],
  }

  package { 'ssmtp':
    ensure => installed,
  }

}
