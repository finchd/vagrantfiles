#puppet master node definition
node 'nomadpuppetserver.local' {

  #Apache modules for PuppetBoard:
  include profile::apache::wsgi
  
  #Profiles for Puppetboard itself and its vhost:
  include profile::puppetboard
  
  #Profile for setting up puppetexplorer:
  include profile::puppetexplorer
 
  #Include the rsyslog::client profile to set up logging
  #include profile::rsyslog::client

  #Include a profile that sets up our usual SSH settings:
  include profile::ssh

  #Include a profile that sets up NTP
  include profile::ntp::client

  #Include the role that sets up PuppetDB, the Puppet master to work with PuppetDB and Puppetboard:
  include role::puppetdb::puppet_master_and_puppetdb_server_with_puppetboard
  
  #Set up Hiera:
  include profile::hiera

  #Make this machine a Consul server:
  #include profile::consul::server

  #Install Heka and configure it with some plugins:
  include profile::heka

}

node 'nomadserver1.local' {

  ###############################
  # SSH installation/setup
  ###############################

  #Include a profile that sets up our usual SSH settings:
  include profile::ssh

  ###############################
  # rsyslog installation/setup
  ###############################

  #Include the rsyslog::client profile to set up logging
  #include profile::rsyslog::client

  ###############################
  # NTP installation/setup
  ###############################

  #Include a profile that sets up NTP
  include profile::ntp::client

  ###############################
  # Heka installation/setup
  ###############################

  #Install Heka and configure it with some plugins:
  include profile::heka

  ###############################
  # collectd installation/setup
  ###############################

  #Install Collectd so we can get metrics from this machine into Riemann/InfluxDB:
  #include profile::collectd
  
  #Gather NTP stats:
  #include profile::collectd::system_metrics
  
  #Gather network metrics
  #include profile::collectd::network_metrics
  
  #Send collectd metrics to the monitoring VM
  #include profile::collectd::write_graphite

}

node 'nomadserver2.local' {

  ###############################
  # SSH installation/setup
  ###############################

  #Include a profile that sets up our usual SSH settings:
  include profile::ssh

  ###############################
  # rsyslog installation/setup
  ###############################

  #Include the rsyslog::client profile to set up logging
  #include profile::rsyslog::client

  ###############################
  # NTP installation/setup
  ###############################

  #Include a profile that sets up NTP
  include profile::ntp::client

  ###############################
  # Heka installation/setup
  ###############################

  #Install Heka and configure it with some plugins:
  include profile::heka

  ###############################
  # collectd installation/setup
  ###############################

  #Install Collectd so we can get metrics from this machine into Riemann/InfluxDB:
  #include profile::collectd
  
  #Gather NTP stats:
  #include profile::collectd::system_metrics
  
  #Gather network metrics
  #include profile::collectd::network_metrics
  
  #Send collectd metrics to the monitoring VM
  #include profile::collectd::write_graphite

}

node 'nomadserver3.local' {

  ###############################
  # SSH installation/setup
  ###############################

  #Include a profile that sets up our usual SSH settings:
  include profile::ssh

  ###############################
  # rsyslog installation/setup
  ###############################

  #Include the rsyslog::client profile to set up logging
  #include profile::rsyslog::client

  ###############################
  # NTP installation/setup
  ###############################

  #Include a profile that sets up NTP
  include profile::ntp::client

  ###############################
  # Heka installation/setup
  ###############################

  #Install Heka and configure it with some plugins:
  include profile::heka

  ###############################
  # collectd installation/setup
  ###############################

  #Install Collectd so we can get metrics from this machine into Riemann/InfluxDB:
  #include profile::collectd
  
  #Gather NTP stats:
  #include profile::collectd::system_metrics
  
  #Gather network metrics
  #include profile::collectd::network_metrics
  
  #Send collectd metrics to the monitoring VM
  #include profile::collectd::write_graphite

}

node 'nomadclient1.local' {

  ###############################
  # Docker installation/setup
  ###############################

  include profile::docker

  ###############################
  # SSH installation/setup
  ###############################

  #Include a profile that sets up our usual SSH settings:
  include profile::ssh

  ###############################
  # rsyslog installation/setup
  ###############################

  #Include the rsyslog::client profile to set up logging
  #include profile::rsyslog::client

  ###############################
  # NTP installation/setup
  ###############################

  #Include a profile that sets up NTP
  include profile::ntp::client

  ###############################
  # Heka installation/setup
  ###############################

  #Install Heka and configure it with some plugins:
  include profile::heka

  ###############################
  # collectd installation/setup
  ###############################

  #Install Collectd so we can get metrics from this machine into Riemann/InfluxDB:
  #include profile::collectd
  
  #Gather NTP stats:
  #include profile::collectd::system_metrics
  
  #Gather network metrics
  #include profile::collectd::network_metrics
  
  #Send collectd metrics to the monitoring VM
  #include profile::collectd::write_graphite

}

node 'nomadclient2.local' {

  ###############################
  # Docker installation/setup
  ###############################

  include profile::docker

  ###############################
  # SSH installation/setup
  ###############################

  #Include a profile that sets up our usual SSH settings:
  include profile::ssh

  ###############################
  # rsyslog installation/setup
  ###############################

  #Include the rsyslog::client profile to set up logging
  #include profile::rsyslog::client

  ###############################
  # NTP installation/setup
  ###############################

  #Include a profile that sets up NTP
  include profile::ntp::client

  ###############################
  # Heka installation/setup
  ###############################

  #Install Heka and configure it with some plugins:
  include profile::heka

  ###############################
  # collectd installation/setup
  ###############################

  #Install Collectd so we can get metrics from this machine into Riemann/InfluxDB:
  #include profile::collectd
  
  #Gather NTP stats:
  #include profile::collectd::system_metrics
  
  #Gather network metrics
  #include profile::collectd::network_metrics
  
  #Send collectd metrics to the monitoring VM
  #include profile::collectd::write_graphite

}

node 'nomadclient3.local' {

  ###############################
  # Docker installation/setup
  ###############################

  include profile::docker

  ###############################
  # SSH installation/setup
  ###############################

  #Include a profile that sets up our usual SSH settings:
  include profile::ssh

  ###############################
  # rsyslog installation/setup
  ###############################

  #Include the rsyslog::client profile to set up logging
  #include profile::rsyslog::client

  ###############################
  # NTP installation/setup
  ###############################

  #Include a profile that sets up NTP
  include profile::ntp::client

  ###############################
  # Heka installation/setup
  ###############################

  #Install Heka and configure it with some plugins:
  include profile::heka

  ###############################
  # collectd installation/setup
  ###############################

  #Install Collectd so we can get metrics from this machine into Riemann/InfluxDB:
  #include profile::collectd
  
  #Gather NTP stats:
  #include profile::collectd::system_metrics
  
  #Gather network metrics
  #include profile::collectd::network_metrics
  
  #Send collectd metrics to the monitoring VM
  #include profile::collectd::write_graphite

}

node 'dockerregistry.local' {

  ###############################
  # Docker installation/setup
  ###############################

  include profile::docker

  ###############################
  # SSH installation/setup
  ###############################

  #Include a profile that sets up our usual SSH settings:
  include profile::ssh

  ###############################
  # rsyslog installation/setup
  ###############################

  #Include the rsyslog::client profile to set up logging
  #include profile::rsyslog::client

  ###############################
  # NTP installation/setup
  ###############################

  #Include a profile that sets up NTP
  include profile::ntp::client

  ###############################
  # Heka installation/setup
  ###############################

  #Install Heka and configure it with some plugins:
  include profile::heka

  ###############################
  # collectd installation/setup
  ###############################

  #Install Collectd so we can get metrics from this machine into Riemann/InfluxDB:
  #include profile::collectd
  
  #Gather NTP stats:
  #include profile::collectd::system_metrics
  
  #Gather network metrics
  #include profile::collectd::network_metrics
  
  #Send collectd metrics to the monitoring VM
  #include profile::collectd::write_graphite

}

node 'haproxy1.local' {

  ###############################
  # SSH installation/setup
  ###############################

  #Include a profile that sets up our usual SSH settings:
  include profile::ssh

  ###############################
  # rsyslog installation/setup
  ###############################

  #Include the rsyslog::client profile to set up logging
  #include profile::rsyslog::client

  ###############################
  # NTP installation/setup
  ###############################

  #Include a profile that sets up NTP
  include profile::ntp::client

  ###############################
  # Heka installation/setup
  ###############################

  #Install Heka and configure it with some plugins:
  include profile::heka

  ###############################
  # collectd installation/setup
  ###############################

  #Install Collectd so we can get metrics from this machine into Riemann/InfluxDB:
  #include profile::collectd
  
  #Gather NTP stats:
  #include profile::collectd::system_metrics
  
  #Gather network metrics
  #include profile::collectd::network_metrics
  
  #Send collectd metrics to the monitoring VM
  #include profile::collectd::write_graphite

}

node 'nomadmonitoring.local' {

  #Install Java so we can run Riemann; use the -> arrow so that it gets instaleld:
  package {'java-1.8.0-openjdk':
    ensure => installed,
  }

  ###############################
  # SSH installation/setup
  ###############################

  #Include a profile that sets up our usual SSH settings:
  include profile::ssh

  ###############################
  # rsyslog installation/setup
  ###############################

  #Include the rsyslog::client profile to set up logging
  #include profile::rsyslog::client

  ###############################
  # NTP installation/setup
  ###############################

  #Include a profile that sets up NTP
  include profile::ntp::client

  ###############################
  # Heka installation/setup
  ###############################

  #Install Heka and configure it with some plugins:
  include profile::heka

  ###############################
  # Elasticsearch installation/setup
  ###############################

  #Include Elasticsearch
  include profile::elasticsearch

  ###############################
  # collectd installation/setup
  ###############################

  #Install Collectd so we can get metrics from this machine into Riemann/InfluxDB:
  #include profile::collectd
  
  #Gather NTP stats:
  #include profile::collectd::system_metrics
  
  #Gather network metrics
  #include profile::collectd::network_metrics
  
  #Send collectd metrics to the monitoring VM
  #include profile::collectd::write_graphite

}