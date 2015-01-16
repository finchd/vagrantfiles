#puppet master node definition
node 'icinga2master.local' {

  #Apache modules for PuppetBoard:
  include profile::apache::wsgi
  
  #Profiles for Puppetboard itself and its vhost:
  include profile::puppetboard
  
  #Profile for setting up puppetexplorer:
  include profile::puppetexplorer
 
  #Include the rsyslog::client profile to set up logging
  include profile::rsyslog::client

  #Include a profile that sets up our usual SSH settings:
  include profile::ssh

  #Include a profile that sets up NTP
  include profile::ntp::client

  #Include the role that sets up PuppetDB, the Puppet master to work with PuppetDB and Puppetboard:
  include role::puppetdb::puppet_master_and_puppetdb_server_with_puppetboard
  
  #Make this machine a Consul server for all of the Icinga 2 client and server VMs
  include profile::consul::server

}

#An Ubuntu 14.04 Icinga2 server node
node 'trustyicinga2server.local' { 

  #Include a profile that sets up our usual SSH settings:
  include profile::ssh

  #Include the rsyslog::client profile to set up logging
  include profile::rsyslog::client

  #Include a profile that sets up NTP
  include profile::ntp::client

  include role::icinga2::server

  #Make this machine a Consul client:
  include profile::consul::client


}

#An Ubuntu 14.10 Icinga2 server node
node 'utopicicinga2server.local' {

  #Include a profile that sets up our usual SSH settings:
  include profile::ssh

  #Include the rsyslog::client profile to set up logging
  include profile::rsyslog::client

  #Include a profile that sets up NTP
  include profile::ntp::client

  include role::icinga2::server

  #Make this machine a Consul client:
  include profile::consul::client

}

#An Ubuntu 12.04 Icinga2 server node
node 'preciseicinga2server.local' {

  #Include a profile that sets up our usual SSH settings:
  include profile::ssh

  #Include the rsyslog::client profile to set up logging
  include profile::rsyslog::client

  #Include a profile that sets up NTP
  include profile::ntp::client

  include role::icinga2::server

  #Make this machine a Consul client:
  include profile::consul::client

}

#CentOS 6 Icinga 2 server node
node 'centos6icinga2server.local' {

  #Include a profile that sets up our usual SSH settings:
  include profile::ssh

  #Include the rsyslog::client profile to set up logging
  include profile::rsyslog::client

  #Include a profile that sets up NTP
  include profile::ntp::client

  include role::icinga2::server

  #Make this machine a Consul client:
  include profile::consul::client

}

#A CentOS 7 Icinga 2 server node
node 'centos7icinga2server.local' {

  #Include a profile that sets up our usual SSH settings:
  include profile::ssh

  #Include the rsyslog::client profile to set up logging
  include profile::rsyslog::client

  #Include a profile that sets up NTP
  include profile::ntp::client

  include role::icinga2::server

  #Make this machine a Consul client:
  include profile::consul::client

}

#A Debian 7 Icinga2 server node
node 'debian7icinga2server.local' {

  #Include a profile that sets up our usual SSH settings:
  include profile::ssh

  #Include the rsyslog::client profile to set up logging
  include profile::rsyslog::client

  #Include a profile that sets up NTP
  include profile::ntp::client

  include role::icinga2::server

  #Make this machine a Consul client:
  include profile::consul::client

}

#An Ubuntu 14.04 Icinga 2 client node
node 'trustyicinga2nrpeclient.local' {

  #Include a profile that sets up our usual SSH settings:
  include profile::ssh

  #Include the rsyslog::client profile to set up logging
  include profile::rsyslog::client

  #Include a profile that sets up NTP
  include profile::ntp::client

  include role::icinga2::nrpeclient

  #Make this machine a Consul client:
  include profile::consul::client

}

#An Ubuntu 14.10 Icinga 2 client node
node 'utopicicinga2nrpeclient.local' {

  #Include a profile that sets up our usual SSH settings:
  include profile::ssh

  #Include the rsyslog::client profile to set up logging
  include profile::rsyslog::client

  #Include a profile that sets up NTP
  include profile::ntp::client

  include role::icinga2::nrpeclient

  #Make this machine a Consul client:
  include profile::consul::client

}

#An Ubuntu 12.04 Icinga 2 client node
node 'preciseicinga2nrpeclient.local' {

  #Include a profile that sets up our usual SSH settings:
  include profile::ssh

  #Include the rsyslog::client profile to set up logging
  include profile::rsyslog::client

  #Include a profile that sets up NTP
  include profile::ntp::client

  include role::icinga2::nrpeclient

  #Make this machine a Consul client:
  include profile::consul::client

}

#A CentOS 6 Icinga 2 client node
node 'centos6icinga2nrpeclient.local' {

  #Include a profile that sets up our usual SSH settings:
  include profile::ssh

  #Include the rsyslog::client profile to set up logging
  include profile::rsyslog::client

  #Include a profile that sets up NTP
  include profile::ntp::client

  include role::icinga2::nrpeclient

  #Make this machine a Consul client:
  include profile::consul::client

}

#A CentOS 7 Icinga 2 client node
node 'centos7icinga2nrpeclient.local' {

  #Include a profile that sets up our usual SSH settings:
  include profile::ssh

  #Include the rsyslog::client profile to set up logging
  include profile::rsyslog::client

  #Include a profile that sets up NTP
  include profile::ntp::client

  include role::icinga2::nrpeclient

  #Make this machine a Consul client:
  include profile::consul::client

}

#A Debian 7 Icinga 2 client node
node 'debian7icinga2nrpeclient.local' {

  #Include a profile that sets up our usual SSH settings:
  include profile::ssh

  #Include the rsyslog::client profile to set up logging
  include profile::rsyslog::client

  #Include a profile that sets up NTP
  include profile::ntp::client

  include role::icinga2::nrpeclient

  #Make this machine a Consul client:
  include profile::consul::client

}

#An Ubuntu 14.04 Icinga 2 client node
node 'trustyicinga2node.local' {

  #Include a profile that sets up our usual SSH settings:
  include profile::ssh

  #Include the rsyslog::client profile to set up logging
  include profile::rsyslog::client

  #Include a profile that sets up NTP
  include profile::ntp::client

  #Make this machine a Consul client:
  include profile::consul::client

}

#An Ubuntu 14.10 Icinga 2 client node
node 'utopicicinga2node.local' {

  #Include a profile that sets up our usual SSH settings:
  include profile::ssh

  #Include the rsyslog::client profile to set up logging
  include profile::rsyslog::client

  #Include a profile that sets up NTP
  include profile::ntp::client

  #Make this machine a Consul client:
  include profile::consul::client

}

#An Ubuntu 12.04 Icinga 2 client node
node 'preciseicinga2node.local' {

  #Include a profile that sets up our usual SSH settings:
  include profile::ssh

  #Include the rsyslog::client profile to set up logging
  include profile::rsyslog::client

  #Include a profile that sets up NTP
  include profile::ntp::client

  #Make this machine a Consul client:
  include profile::consul::client

}

#A CentOS 6 Icinga 2 client node
node 'centos6icinga2node.local' {

  #Include a profile that sets up our usual SSH settings:
  include profile::ssh

  #Include the rsyslog::client profile to set up logging
  include profile::rsyslog::client

  #Include a profile that sets up NTP
  include profile::ntp::client

  #Make this machine a Consul client:
  include profile::consul::client

}

#A CentOS 7 Icinga 2 client node
node 'centos7icinga2node.local' {

  #Include a profile that sets up our usual SSH settings:
  include profile::ssh

  #Include the rsyslog::client profile to set up logging
  include profile::rsyslog::client

  #Include a profile that sets up NTP
  include profile::ntp::client

  #Make this machine a Consul client:
  include profile::consul::client

}

#A Debian 7 Icinga 2 client node
node 'debian7icinga2node.local' {

  #Include a profile that sets up our usual SSH settings:
  include profile::ssh

  #Include the rsyslog::client profile to set up logging
  include profile::rsyslog::client

  #Include a profile that sets up NTP
  include profile::ntp::client
  
  #Make this machine a Consul client:
  include profile::consul::client

}

node 'icinga2mail.local' {

  #Include a profile that sets up our usual SSH settings:
  include profile::ssh

  #Include the rsyslog::client profile to set up logging
  include profile::rsyslog::client

  #Include a profile that sets up NTP
  include profile::ntp::client

  include role::icinga2::nrpeclient

  #Include the profile that sets up my user account:
  include profile::users

  #Make this machine a Consul client:
  include profile::consul::client

}

node 'usermail.local' {

  #Include a profile that sets up our usual SSH settings:
  include profile::ssh

  #Include the rsyslog::client profile to set up logging
  include profile::rsyslog::client

  #Include a profile that sets up NTP
  include profile::ntp::client

  include role::icinga2::nrpeclient

  #Include a profile that installs and configures Postfix:
  include profile::postfix::server

  #Include the profile that sets up my user account:
  include profile::users

  #Make this machine a Consul client:
  include profile::consul::client

}

node 'icinga2logging.local' {

  #Include a profile that sets up our usual SSH settings:
  include profile::ssh

  #Include the rsyslog::client profile to set up logging
  include profile::rsyslog::client

  #Include a profile that sets up NTP
  include profile::ntp::client

  include role::icinga2::nrpeclient
  
  #Install Apache so we use Kibana 3:
  include profile::apache

  #Install Java...
  include profile::java

  #Include Logstash
  include profile::logstash
  include profile::logstash::config

  #Include Elasticsearch
  include profile::elasticsearch

  #Include the profile that sets up a virtual host for Kibana3:
  include profile::kibana3::apache_virtualhost

  #Make this machine a Consul client:
  include profile::consul::client

}

node 'icinga2metrics.local' {

  #Include a profile that sets up our usual SSH settings:
  include profile::ssh

  #Include the rsyslog::client profile to set up logging
  include profile::rsyslog::client

  #Include a profile that sets up NTP
  include profile::ntp::client

  include role::icinga2::nrpeclient

  #Install Riemann
  include profile::riemann
  
  #Install InfluxDB
  include profile::influxdb
  
  #Include the Grafana profile
  include profile::grafana

  #Make this machine a Consul client:
  include profile::consul::client


}