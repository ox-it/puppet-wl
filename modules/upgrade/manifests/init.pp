# This class sets up automatic upgrading
class upgrade {
  
  package { 'unattended-upgrades':
    ensure => installed,
  }

}
