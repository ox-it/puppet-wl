# Your nodes go here
node default {
  include ssh
  include users
}

node 'chedder' inherits default {
  include serial
}

# Node which runs our copy of nexus
node 'feta' inherits default {
  include serial
  include kerberos
  include nexus
}
