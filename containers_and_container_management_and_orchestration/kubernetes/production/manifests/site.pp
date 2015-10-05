#puppet master node definition
node 'kubernetespuppetserver.local' {

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

node 'kubernetesserver1.local' {

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

node 'kubernetesserver2.local' {

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

node 'kubernetesserver3.local' {

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

node 'kubernetesclient1.local' {

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

node 'kubernetesclient2.local' {

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

node 'kubernetesclient3.local' {

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

node 'kubernetesmonitoring.local' {

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