# For managing tty on serial ports
class serial {

  $serialport = 'ttyS0'

  # Must be install, but just in case
  package { 'util-linux':
    ensure => installed,
  }

  file { "/etc/init/${serialport}.conf":
    ensure => file,
    content => template('serial/ttySx.conf.erb'),
  }

  service { $serialport:
    name => $serialport,
    ensure => running,
    enabled => true,
    subscribe => File["/etc/init/${serialport}.conf"],
    require => Package['util-linux'],
  }

}
