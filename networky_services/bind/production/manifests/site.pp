#puppet master node definition
node 'dnspuppetserver.local' {

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

node 'dnsserver1.local' {

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
  # Consul installation/setup
  ###############################

  #Make this machine a Consul client:
  #include profile::consul::client

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

  ###############################
  # NRPE installation/configuration
  ###############################

  #Install and configure NRPE
  #include profile::icinga2::nrpe
  
  #Include NRPE command definitions
  #include profile::icinga2::nrpe::objects

  ###############################
  # BIND installation/setup
  ###############################
  
  #Include the BIND base profile so that we get the host export
  #for monitoring set up:
  include profile::bind  
  include profile::bind::master

}

node 'dnsserver2.local' {

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
  # Consul installation/setup
  ###############################

  #Make this machine a Consul client:
  #include profile::consul::client

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

  ###############################
  # NRPE installation/configuration
  ###############################

  #Install and configure NRPE
  #include profile::icinga2::nrpe
  
  #Include NRPE command definitions
  #include profile::icinga2::nrpe::objects

  ###############################
  # BIND installation/setup
  ###############################
  
  #Include the BIND base profile so that we get the host export
  #for monitoring set up:
  include profile::bind  
  include profile::bind::master

}

node 'dnsreplica1.local' {

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
  # Consul installation/setup
  ###############################

  #Make this machine a Consul client:
  #include profile::consul::client

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

  ###############################
  # NRPE installation/configuration
  ###############################

  #Install and configure NRPE
  #include profile::icinga2::nrpe
  
  #Include NRPE command definitions
  #include profile::icinga2::nrpe::objects

  ###############################
  # BIND installation/setup
  ###############################
  
  #Include the BIND base profile so that we get the host export
  #for monitoring set up:
  include profile::bind  
  #include profile::bind::master

}

node 'dnsreplica2.local' {

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
  # Consul installation/setup
  ###############################

  #Make this machine a Consul client:
  #include profile::consul::client

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

  ###############################
  # NRPE installation/configuration
  ###############################

  #Install and configure NRPE
  #include profile::icinga2::nrpe
  
  #Include NRPE command definitions
  #include profile::icinga2::nrpe::objects

  ###############################
  # BIND installation/setup
  ###############################
  
  #Include the BIND base profile so that we get the host export
  #for monitoring set up:
  include profile::bind  
  #include profile::bind::master

}

node 'dnssubserver1.local' {

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
  # Consul installation/setup
  ###############################

  #Make this machine a Consul client:
  #include profile::consul::client

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

  ###############################
  # NRPE installation/configuration
  ###############################

  #Install and configure NRPE
  #include profile::icinga2::nrpe
  
  #Include NRPE command definitions
  #include profile::icinga2::nrpe::objects

  ###############################
  # BIND installation/setup
  ###############################
  
  #Include the BIND base profile so that we get the host export
  #for monitoring set up:
  include profile::bind  
  #include profile::bind::master

}

node 'dnssubserver2.local' {

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
  # Consul installation/setup
  ###############################

  #Make this machine a Consul client:
  #include profile::consul::client

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

  ###############################
  # NRPE installation/configuration
  ###############################

  #Install and configure NRPE
  #include profile::icinga2::nrpe
  
  #Include NRPE command definitions
  #include profile::icinga2::nrpe::objects

  ###############################
  # BIND installation/setup
  ###############################
  
  #Include the BIND base profile so that we get the host export
  #for monitoring set up:
  include profile::bind  
  #include profile::bind::master

}

node 'dnsmonitoring.local' {

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

}
