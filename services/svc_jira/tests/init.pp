include svc_jira

$location = "Oxfordshire"
$country = "GB"
$state = "Oxford"
$organization = "University of Oxford"
$unit = "IT Services"
$commonname = "jira.oucs.ox.ac.uk"
 
$subject = "/C=${country}/ST=${state}/L=${location}/O=${organization}/OU=${unit}/CN=${commonname}"
$createcertificate = "/usr/bin/openssl req -new -newkey rsa:2048 -x509 -days 365 -nodes -out certs/${commonname}.crt -keyout private/${commonname}.key -subj \"${subject}\""
 
exec { "openssl-csr":
  command => $createcertificate,
  cwd => '/etc/ssl/',
  creates => ["/etc/ssl/private/${commonname}.key", "/etc/ssl/certs/${commonname}.key"],
}