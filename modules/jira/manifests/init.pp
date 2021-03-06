# Class: jira
#
# This module manages jira
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
class jira (
	$user = "jira",	
	$database_name = "jira",
	$database_type = "postgres72",
	$database_schema = "public",
	$database_driver = "org.postgresql.Driver",
	$database_driver_jar = "postgresql-9.1-902.jdbc4.jar",
	$database_driver_source = "puppet:///modules/jira/db/postgresql-9.1-902.jdbc4.jar",
	$database_url = "jdbc:postgresql://localhost/jira",
	$database_user = "jira",
	$database_pass = "jira",
	$number = 2,
	$version = "5.2.7",
	$jira_jars_version = "6.2-m04",
	$contextroot = "jira",
	$webapp_base = "/srv",
    $http = true,
    $ajp = true,
){
	
# configuration
	$jira_build = "atlassian-jira-${version}" 
	$tarball = "${jira_build}-war.tar.gz"
	$download_dir = "/tmp"
	$downloaded_tarball = "${download_dir}/${tarball}"
	$download_url = "http://www.atlassian.com/software/jira/downloads/binary/${tarball}"
	$library_download_url = "http://www.atlassian.com/software/jira/downloads/binary/jira-jars-tomcat-distribution-${jira_jars_version}-tomcat-6x.zip"
	$build_parent_dir = "${webapp_base}/${user}/build"
	$build_dir = "${build_parent_dir}/${version}"
	$jira_dir = "${webapp_base}/${user}"
	$jira_home = "${webapp_base}/${user}/jira-home"
	
	$webapp_context = $contextroot ? {
	  '/' => '',	
      '' => '',
      default  => "/${contextroot}"
    }
    
    $webapp_war = $contextroot ? {
    	'' => "ROOT.war",
    	'/' => "ROOT.war",
    	default => "${contextroot}.war"	
    }
	
# we need the unzip package
	if (!defined(Package["unzip"])) {
		package{ "unzip":
			ensure => present,
		}
	}

    # https://jira.atlassian.com/browse/JRA-23082
    # OpenJDK doesn't work without fontconfig installed.
    package { "fontconfig" :
        ensure => present,
    }
	
# download the WAR-EAR distribution of JIRA
	exec { "download-jira":
		command => "/usr/bin/wget -O ${downloaded_tarball} ${download_url}",
		require => Tomcat::Webapp::User[$user],
		creates => $downloaded_tarball,
		timeout => 1200,	
	}
	
	file { $downloaded_tarball :
		require => Exec["download-jira"],
		ensure => file,
	}
	
# prepare the jira build
	file { $build_parent_dir:
		ensure => directory,
		owner => $user,
		group => $user,
		require => Tomcat::Webapp::User[$user],
	}
	
	exec { "extract-jira":
		command => "/bin/tar -xvzf ${tarball} && mv ${jira_build}-war ${build_dir}",
		cwd => $download_dir,
		user => $user,
		creates => "${build_dir}/build.sh",
		timeout => 1200,
		require => [File[$downloaded_tarball],File[$build_parent_dir]],
		notify => [
			Exec['clean-jira'],
			Exec['clean-jira-libs'],	
		]	
	}

	file { $build_dir:
		ensure => directory,
		owner => $user,
		group => $user,
		require => Exec["extract-jira"],
	}
	
	
	file { $jira_home:
		ensure => directory,
		mode => 0755,
		owner => $user,
		group => $user,
		require => Tomcat::Webapp::User[$user],
	}
	
	file { "jira.properties":
		path => "${build_dir}/edit-webapp/WEB-INF/classes/jira-application.properties",
		content => template("jira/jira-application.properties.erb"),
		ensure => present,
		require => [
			Exec["extract-jira"],
			Exec["clean-jira-edit-webapp"],
		],
		notify => Exec["clean-jira"],

	}
	
	file { "dbconfig.xml" :
		path => "${jira_home}/dbconfig.xml",
		ensure => present,
		content => template("jira/dbconfig.xml.erb"),
		require => Exec["extract-jira"],
		notify => Exec["clean-jira"],
		owner => root,
		group => $user,
		mode => 640,
	}
	
# clean any customisations
	exec { "clean-jira-edit-webapp":
		command => "/bin/rm -rf ${build_dir}/edit-webapp/WEB-INF/classes/* ${build_dir}/edit-webapp/WEB-INF/lib",
		refreshonly => true,
		notify => Exec["build-jira"],
	}
	
# clean the previous JIRA libraries
	exec { "clean-jira-libs":
		command => "/bin/rm -rf ${webapp_base}/${user}/tomcat/lib/*",
		user => $user,
		refreshonly => true,
		notify => Exec["download-extra-jira-libs"],
		require => [
			Tomcat::Webapp::Tomcat[$user]
		],
	}

	
# clean the previous JIRA war-file	
	exec { "clean-jira":
		command => "/bin/rm -rf ${webapp_base}/${user}/tomcat/webapps/*",
		user => $user,
		refreshonly => true,
		notify => Exec["build-jira"],
		require => [
			Tomcat::Webapp::Tomcat[$user]
		],
	}

	
# build the JIRA war-file	
# don't ever call nofify this, as you always need to have cleaned before hand.
	exec { "build-jira":
		command => "/bin/sh build.sh && /bin/cp ${build_dir}/dist-tomcat/tomcat-6/${jira_build}.war ${webapp_base}/${user}/tomcat/webapps/${webapp_war}",
		user => $user,
		cwd => $build_dir,
		timeout => 0,
		refreshonly => true,
		require => [
			File["jira.properties"],
			File["dbconfig.xml"],
			Tomcat::Webapp::Tomcat[$user]
		],
		notify => Tomcat::Webapp::Service[$user]
	}
	
# download extra libraries needed by JIRA
	exec { "download-extra-jira-libs":
		command => "/usr/bin/wget -O /tmp/jira-jars-${jira_jars_version}.zip ${library_download_url}",
		creates => "/tmp/jira-jars-${jira_jars_version}.zip",
		refreshonly => true,
		timeout => 1200,	
		notify => Exec["extract-extra-jira-libs"],
		require => Tomcat::Webapp::User[$user],
	}
	
	exec { "extract-extra-jira-libs":
		command => "/usr/bin/unzip -d ${jira_dir}/tomcat/lib /tmp/jira-jars-${jira_jars_version}.zip",
		user => $user,
		refreshonly => true,
		require => [
			Tomcat::Webapp::Tomcat[$user],
			Package["unzip"]
		]
	}

# the database driver jar
	file { 'jira-db-driver':
		path => "${jira_dir}/tomcat/lib/${database_driver_jar}", 
		source => $database_driver_source,
		ensure => file,
		owner => $user,
		group => $user,
		require => [
			Tomcat::Webapp::Tomcat[$user],
			Exec["extract-extra-jira-libs"]
		]
	}    
	
# manage the Tomcat instance
	tomcat::webapp { "${user}" :
		username => $user, 
		number => $number,
		webapp_base => $webapp_base,
		java_opts => "-server -Dorg.apache.jasper.runtime.BodyContentImpl.LIMIT_BUFFER=true -Dmail.mime.decodeparameters=true -Xms786m -Xmx786m -XX:MaxPermSize=384m -Djava.awt.headless=true",
		server_host_config => template("jira/context.erb"),
        ajp => $ajp,
        http => $http,
		service_require => [
			Exec['build-jira'],
			File['jira-db-driver'],
			File[$jira_home],
			Exec['extract-extra-jira-libs']
		],
		require => Class["tomcat"],
	}
}
