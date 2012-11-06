# For doing the git syncing
class git-sync {

  # There are some scripts in this users home dir that aren't currently 
  # pulled in with puppet.
  user {'git-sync':
    shell => '/bin/bash',
    ensure => present,
    managehome => true,
  }

  # This is needed for the git scripts
  package { 'git':
    ensure => 'installed',
  }

  # This is needed for the initial mirror setup
  package { 'subversion':
    ensure => 'installed',
  }

}

