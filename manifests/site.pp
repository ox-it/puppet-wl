# Your nodes go here
node default {
  include ssh
  include users
}

node 'chedder' inherits default {
  include serial
}
