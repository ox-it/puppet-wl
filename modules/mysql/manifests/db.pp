# Creates a database in MySQL
define mysql::db($name, $owner) {

	exec { "create-mysqldb-${name}" :
		command =>  "mysqladmin create ${name}",
		# -s quiet (no ascii boxes) -N no column heading -r don't escape -e run this SQL
		unless => "mysql -u root -s -N -r -e 'show databases'  | grep -q '${name}'",
		path => ["/bin", "/usr/bin"],
		require => [Class["mysql"],Mysql::User[$owner]],
	}
	
	# Grants rights over the DB
	exec { "grant-mysqldb-${name}" :
		command => "mysql -u root -e \"GRANT ALL ON ${name}.* TO '${owner}'@'localhost';\"",
		unless => "mysql -u root -s -N -r -e \"SHOW GRANTS FOR '${owner}'@'localhost';\" | grep -q '${name}'",
		path => ["/bin", "/usr/bin"],
		require => [Class["mysql"], Exec["create-mysqldb-${name}"]],
	}
}

