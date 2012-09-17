# This is for putting an extra file into the Jira build.
define jira::extra ($file = $title) {
	
	# This is not done as files so that changes in versions no don't break things.
	file { "${jira::build_dir}/edit-webapp/$file" :
		source => "puppet:///modules/jira/extra/$file",
		ensure => "present",
		notify => Exec["clean-jira"],
	}		
	
}