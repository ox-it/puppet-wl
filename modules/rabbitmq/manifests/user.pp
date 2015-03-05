# Creates a user in RabbitMQ
define rabbitmq::user($username = $title, $password) {
	exec { "create-rabbit-user-${username}" :
		command =>  "/usr/sbin/rabbitmqctl add_user ${username} ${password}",
		unless => "/usr/sbin/rabbitmqctl list_users | grep -q '^${username}'",
		require => Class["rabbitmq"],
	}
}
