# For managing tty on serial ports
# It would be nice to have a facter find the serial ports.
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
    enable => true,
    provider => 'upstart',
    subscribe => File["/etc/init/${serialport}.conf"],
    require => Package['util-linux'],
  }

}
