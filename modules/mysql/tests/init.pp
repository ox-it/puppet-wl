include mysql

mysql::user { 'puppet':
	password => 'puppet',
}

mysql::db { 'puppetdb':
	name => 'puppetdb',
	owner => 'puppet'
}
