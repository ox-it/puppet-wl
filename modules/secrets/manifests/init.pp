# This manages secrets
# This module is designed for masterless deployment

class secrets {
    $file = "/etc/puppet-secret"
    $root = file("/etc/puppet-secret")
    
    # There's no point in generating the content of the file as it won't get picked up.
    # That because $secrets::root will already contain the contents of the file
    file { $file :
       replace => "no",
       owner => "root",
       group => "root",
       mode => 600,
   }
}
