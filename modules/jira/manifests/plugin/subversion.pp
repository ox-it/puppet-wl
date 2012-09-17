class jira::plugin::subversion (
	$version = "0.10.11",
) {
	# Configuration
	$download_dir = "/tmp"
	$download_url = "http://maven.atlassian.com/contrib/com/atlassian/jira/plugin/ext/subversion/atlassian-jira-subversion-plugin/${version}/atlassian-jira-subversion-plugin-${version}-distribution.zip"
	$downloaded_zip = "${download_dir}/atlassian-jira-subversion-plugin-${version}-distribution.zip"
	
	# Download the plugin
	exec { "download-plugin-subversion":
		command => "/usr/bin/wget -O ${downloaded_zip} ${download_url}",
		creates => $downloaded_zip,
		timeout => 1200,	
	}
	
	exec { "extract-plugin-subversion":
		command => "/usr/bin/unzip  ${downloaded_zip} ",
		cwd => "${jira::build_parent_dir}",
		user => $user,
		creates => "${jira::build_parent_dir}/atlassian-jira-subversion-plugin-${version}",
		timeout => 1200,
		require => [
			Exec["download-plugin-subversion"],
			Exec["extract-jira"]
		],
		notify => [
			Exec["clean-jira-edit-webapp"],
			Exec["clean-jira"],
		]
	}
	
	# This is not done as files so that changes in versions no don't break things.
	exec { "copy-plugin-subversion-jars":
		command =>"/bin/cp -r ${jira::build_parent_dir}/atlassian-jira-subversion-plugin-${version}/lib ${jira::build_dir}/edit-webapp/WEB-INF",
		creates => [
			"${jira::build_dir}/edit-webapp/WEB-INF/lib/atlassian-jira-subversion-plugin-${version}.jar",
		],
		cwd => $download_dir,
		subscribe => [
			Exec["extract-plugin-subversion"],
		],
	}		
	
}