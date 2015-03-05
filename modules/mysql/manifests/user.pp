# Creates a user in MySQL
define mysql::user($username = $title, $password) {
	exec { "create-mysql-user-${username}" :
		command =>  "/usr/bin/mysql -u root -e \"CREATE USER '${username}'@'localhost' IDENTIFIED BY '${password}';\"",
		unless => "/usr/bin/mysql -u root -N -r -s -e 'SELECT DISTINCT user FROM mysql.user' | grep -q '^${username}\$'",
		require => Class["mysql"],
	}
}
