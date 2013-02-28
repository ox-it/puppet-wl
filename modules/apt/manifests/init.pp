class apt {
  
  # From the ever useful stack overflow:
  # http://stackoverflow.com/questions/10845864/puppet-trick-run-apt-get-update-before-installing-other-packages
  exec { "apt-update":
      command => "/usr/bin/apt-get update"
  }

  Exec["apt-update"] -> Package <| |>
}