#puppet master node definition
node 'dnspuppetmaster.local' {

  #This module is from: https://github.com/puppetlabs/puppetlabs-puppetdb/
  class { 'puppetdb':
    listen_address => '0.0.0.0'
  }

  

  include puppetdb::master::config

  #Apache modules for PuppetBoard:
  class { 'apache': }
  class { 'apache::mod::wsgi': }

  #Configure Puppetboard with this module: https://github.com/nibalizer/puppet-module-puppetboard
  class { 'puppetboard':
    manage_virtualenv => true,
  }

  #A virtualhost for PuppetBoard
  class { 'puppetboard::apache::vhost':
    vhost_name => "puppetboard.${fqdn}",
    port => 80,
  }

  ###############################
  # SSH installation/setup
  ###############################

  #This module is from: https://github.com/saz/puppet-ssh
  class { 'ssh':
    #Export host keys to PuppetDB:
    storeconfigs_enabled => true,
    server_options => {
      #Whether to allow password auth; if set to 'no', only SSH keys can be used:
      #'PasswordAuthentication' => 'no',
      #How many authentication attempts to allow before disconnecting:
      'MaxAuthTries'         => '10',
      'PermitEmptyPasswords' => 'no', 
      'PermitRootLogin'      => 'no',
      'Port'                 => [22],
      'PubkeyAuthentication' => 'yes',
      #Whether to be strict about the permissions on a user's .ssh/ folder and public keys:
      'StrictModes'          => 'yes',
      'TCPKeepAlive'         => 'yes',
      #Whether to do reverse DNS lookups of client IP addresses when they connect:
      'UseDNS'               => 'no',
    },
  }
 
  ###############################
  # rsyslog installation/setup
  ###############################
 
  #This module is from: https://github.com/saz/puppet-rsyslog
  class { 'rsyslog::server':
    enable_tcp => true,
    enable_udp => true,
    port       => '514',
    server_dir => '/var/log/remote/',
  }

  ###############################
  # NTP installation/setup
  ###############################

  #This module is: https://github.com/puppetlabs/puppetlabs-ntp
  class { '::ntp':
    servers  => [ '0.ubuntu.pool.ntp.org', '1.ubuntu.pool.ntp.org', '2.ubuntu.pool.ntp.org', '3.ubuntu.pool.ntp.org' ],
    restrict => ['127.0.0.1', '10.0.1.0 mask 255.255.255.0 kod notrap nomodify nopeer noquery'],
    disable_monitor => true,
  }

  ###############################
  # collectd installation/setup
  ###############################

  #Install Collectd so we can get metrics from this machine into Riemann/InfluxDB:
  class { '::collectd':
    purge        => true,
    recurse      => true,
    purge_config => true,
  }
  
  collectd::plugin { 'df': }
  collectd::plugin { 'disk': }
  collectd::plugin { 'entropy': }
  collectd::plugin { 'memory': }
  collectd::plugin { 'swap': }
  collectd::plugin { 'cpu': }
  collectd::plugin { 'cpufreq': }
  collectd::plugin { 'contextswitch': }
  collectd::plugin { 'processes': }
  collectd::plugin { 'vmem': }
  class { 'collectd::plugin::load':}
  
  #Write the collectd status to the Riemann VM in the Graphite format:
  class { 'collectd::plugin::write_graphite':
    graphitehost => 'dnsmetrics.local',
    protocol => 'tcp',
    graphiteport => 2003,
  }

  #Get network interface data:
  class { 'collectd::plugin::interface':
    interfaces     => ['lo', 'eth0', 'eth1'],
  }

  ###############################
  # Icinga 2 host export stuff
  ###############################

  @@icinga2::object::host { $::fqdn:
    display_name => $::fqdn,
    ipv4_address => $::ipaddress_eth1,
    groups => ['linux_servers', 'clients', 'ssh_servers', 'http_servers', 'dns_servers'],
    vars => {
      os              => 'linux',
      virtual_machine => 'true',
      distro          => $::operatingsystem,
    },
    target_dir => '/etc/icinga2/objects/hosts',
    target_file_name => "${fqdn}.conf"
  }

  ###############################
  # NRPE installation/configuration
  ###############################

  class { 'icinga2::nrpe':
    nrpe_allowed_hosts => ['10.0.1.80', '127.0.0.1'],
    nrpe_listen_port => 5666,
  }

  #Some basic box health stuff
  icinga2::nrpe::command { 'check_users':
    nrpe_plugin_name => 'check_users',
    nrpe_plugin_args => '-w 5 -c 10',
  }
  
  #check_load
  icinga2::nrpe::command { 'check_load':
    nrpe_plugin_name => 'check_load',
    nrpe_plugin_args => '-w 50,40,30 -c 60,50,40',
  }
  
  #check_disk
  icinga2::nrpe::command { 'check_disk':
    nrpe_plugin_name => 'check_disk',
    nrpe_plugin_args => '-w 20% -c 10% -p /',
  }

  #check_total_procs  
  icinga2::nrpe::command { 'check_total_procs':
    nrpe_plugin_name => 'check_procs',
    nrpe_plugin_args => '-w 1000 -c 1500',
  }
 
  #check_zombie_procs
  icinga2::nrpe::command { 'check_zombie_procs':
    nrpe_plugin_name => 'check_procs',
    nrpe_plugin_args => '-w 5 -c 10 -s Z',
  }
  
  icinga2::nrpe::command { 'check_ntp_time':
    nrpe_plugin_name => 'check_ntp_time',
    nrpe_plugin_args => '-H 127.0.0.1',
  }
  
  #Create an NRPE command to monitor MySQL:
  icinga2::nrpe::command { 'check_mysql_service':
    nrpe_plugin_name => 'check_mysql',
    nrpe_plugin_args => '-H 127.0.0.1 -u root -p horsebatterystaple',
  }

}

node 'dnsmaster1.local' {

  ###############################
  # SSH installation/setup
  ###############################

  #This module is from: https://github.com/saz/puppet-ssh
  class { 'ssh':
    #Export host keys to PuppetDB:
    storeconfigs_enabled => true,
    server_options => {
      #Whether to allow password auth; if set to 'no', only SSH keys can be used:
      #'PasswordAuthentication' => 'no',
      #How many authentication attempts to allow before disconnecting:
      'MaxAuthTries'         => '10',
      'PermitEmptyPasswords' => 'no', 
      'PermitRootLogin'      => 'no',
      'Port'                 => [22],
      'PubkeyAuthentication' => 'yes',
      #Whether to be strict about the permissions on a user's .ssh/ folder and public keys:
      'StrictModes'          => 'yes',
      'TCPKeepAlive'         => 'yes',
      #Whether to do reverse DNS lookups of client IP addresses when they connect:
      'UseDNS'               => 'no',
    },
  }

  ###############################
  # rsyslog installation/setup
  ###############################

  #This module is from: https://github.com/saz/puppet-rsyslog
  class { 'rsyslog::client':
    log_remote     => true,
    remote_type    => 'tcp',
    log_local      => true,
    log_auth_local => true,
    custom_config  => undef,
    server         => 'dnslogging.local',
    port           => '5514',
  }

  ###############################
  # NTP installation/setup
  ###############################

  #This module is: https://github.com/puppetlabs/puppetlabs-ntp
  class { '::ntp':
    servers  => [ '0.ubuntu.pool.ntp.org', '1.ubuntu.pool.ntp.org', '2.ubuntu.pool.ntp.org', '3.ubuntu.pool.ntp.org' ],
    restrict => ['127.0.0.1', '10.0.1.0 mask 255.255.255.0 kod notrap nomodify nopeer noquery'],
    disable_monitor => true,
  }
 
  ###############################
  # collectd installation/setup
  ###############################

  #Install Collectd so we can get metrics from this machine into Riemann/InfluxDB:
  class { '::collectd':
    purge        => true,
    recurse      => true,
    purge_config => true,
  }
  
  collectd::plugin { 'df': }
  collectd::plugin { 'disk': }
  collectd::plugin { 'entropy': }
  collectd::plugin { 'memory': }
  collectd::plugin { 'swap': }
  collectd::plugin { 'cpu': }
  collectd::plugin { 'cpufreq': }
  collectd::plugin { 'contextswitch': }
  collectd::plugin { 'processes': }
  collectd::plugin { 'vmem': }
  class { 'collectd::plugin::load':}
  
  #Write the collectd status to the Riemann VM in the Graphite format:
  class { 'collectd::plugin::write_graphite':
    graphitehost => 'dnsmetrics.local',
    protocol => 'tcp',
    graphiteport => 2003,
  }

  #Get network interface data:
  class { 'collectd::plugin::interface':
    interfaces     => ['lo', 'eth0', 'eth1'],
  }
  
  #BIND module is from: https://github.com/thias/puppet-bind
  include bind
  bind::server::conf { '/etc/bind/named.conf':
    acls => {
      'rfc1918' => [ '10/8', '172.16/12', '192.168/16' ],
      'local'   => [ '127.0.0.1' ],
      '10net'   => [ '10.0.0.0/24', '10.0.1.0/24', '10.1.1.0/24', '10.1.0.0/24'],
    },
    directory => '/etc/bind/',
    listen_on_addr    => [ '127.0.0.1' ],
    listen_on_v6_addr => [ '::1' ],
    forwarders        => [ '8.8.8.8', '8.8.4.4' ],
    allow_query       => [ 'localhost', 'local' ],
    recursion         => 'no',
    allow_recursion   => [ 'localhost', 'local', '10net'],
    #Include some other zone files for localhost and loopback zones:
    includes => ['/etc/bind/named.conf.local', '/etc/bind/named.conf.default-zones'],
    zones => {
      #root hints zone
      '.' => [
        'type hint',
        'file "/etc/bind/db.root"',
      ], 
      'zone1.local' => [
      'type master',
      'file "zone1.local"',
      'allow-query { any; }',
      'allow-transfer { 10net; }',
      'allow-update { local; }',
      ],
    'zone2.local' => [
      'type master',
      'file "zone2.local"',
      'allow-query { any; }',
      'allow-transfer { 10net; }',
      'allow-update { local; }',
      ],
    'zone3.local' => [
      'type master',
      'file "zone3.local"',
      'allow-query { any; }',
      'allow-transfer { 10net; }',
      'allow-update { local; }',
      ],
    'zone4.local' => [
      'type master',
      'file "zone4.local"',
      'allow-query { any; }',
      'allow-transfer { 10net; }',
      'allow-update { local; }',
      ],
    'zone5.local' => [
      'type master',
      'file "zone5.local"',
      'allow-query { any; }',
      'allow-transfer { 10net; }',
      'allow-update { local; }',
      ],
    }
  }

  ###############################
  # Icinga 2 host export stuff
  ###############################

  @@icinga2::object::host { $::fqdn:
    display_name => $::fqdn,
    ipv4_address => $::ipaddress_eth1,
    groups => ['linux_servers', 'clients', 'ssh_servers', 'dns_servers'],
    vars => {
      os              => 'linux',
      virtual_machine => 'true',
      distro          => $::operatingsystem,
    },
    target_dir => '/etc/icinga2/objects/hosts',
    target_file_name => "${fqdn}.conf"
  }

 ###############################
  # NRPE installation/configuration
  ###############################

  class { 'icinga2::nrpe':
    nrpe_allowed_hosts => ['10.0.1.80', '127.0.0.1'],
    nrpe_listen_port => 5666,
  }

  #Some basic box health stuff
  icinga2::nrpe::command { 'check_users':
    nrpe_plugin_name => 'check_users',
    nrpe_plugin_args => '-w 5 -c 10',
  }
  
  #check_load
  icinga2::nrpe::command { 'check_load':
    nrpe_plugin_name => 'check_load',
    nrpe_plugin_args => '-w 50,40,30 -c 60,50,40',
  }
  
  #check_disk
  icinga2::nrpe::command { 'check_disk':
    nrpe_plugin_name => 'check_disk',
    nrpe_plugin_args => '-w 20% -c 10% -p /',
  }

  #check_total_procs  
  icinga2::nrpe::command { 'check_total_procs':
    nrpe_plugin_name => 'check_procs',
    nrpe_plugin_args => '-w 1000 -c 1500',
  }
 
  #check_zombie_procs
  icinga2::nrpe::command { 'check_zombie_procs':
    nrpe_plugin_name => 'check_procs',
    nrpe_plugin_args => '-w 5 -c 10 -s Z',
  }
  
  icinga2::nrpe::command { 'check_ntp_time':
    nrpe_plugin_name => 'check_ntp_time',
    nrpe_plugin_args => '-H 127.0.0.1',
  }
  
  #Create an NRPE command to monitor MySQL:
  icinga2::nrpe::command { 'check_mysql_service':
    nrpe_plugin_name => 'check_mysql',
    nrpe_plugin_args => '-H 127.0.0.1 -u root -p horsebatterystaple',
  }

}

node 'dnsmaster2.local' {

  ###############################
  # SSH installation/setup
  ###############################

  #This module is from: https://github.com/saz/puppet-ssh
  class { 'ssh':
    #Export host keys to PuppetDB:
    storeconfigs_enabled => true,
    server_options => {
      #Whether to allow password auth; if set to 'no', only SSH keys can be used:
      #'PasswordAuthentication' => 'no',
      #How many authentication attempts to allow before disconnecting:
      'MaxAuthTries'         => '10',
      'PermitEmptyPasswords' => 'no', 
      'PermitRootLogin'      => 'no',
      'Port'                 => [22],
      'PubkeyAuthentication' => 'yes',
      #Whether to be strict about the permissions on a user's .ssh/ folder and public keys:
      'StrictModes'          => 'yes',
      'TCPKeepAlive'         => 'yes',
      #Whether to do reverse DNS lookups of client IP addresses when they connect:
      'UseDNS'               => 'no',
    },
  }

  ###############################
  # rsyslog installation/setup
  ###############################

  #This module is from: https://github.com/saz/puppet-rsyslog
  class { 'rsyslog::client':
    log_remote     => true,
    remote_type    => 'tcp',
    log_local      => true,
    log_auth_local => true,
    custom_config  => undef,
    server         => 'dnslogging.local',
    port           => '5514',
  }

  ###############################
  # NTP installation/setup
  ###############################

  #This module is: https://github.com/puppetlabs/puppetlabs-ntp
  class { '::ntp':
    servers  => [ '0.centos.pool.ntp.org', '1.centos.pool.ntp.org', '2.centos.pool.ntp.org', '3.centos.pool.ntp.org' ],
    restrict => ['127.0.0.1', '10.0.1.0 mask 255.255.255.0 kod notrap nomodify nopeer noquery'],
    disable_monitor => true,
  }

  ###############################
  # collectd installation/setup
  ###############################

  #Install Collectd so we can get metrics from this machine into Riemann/InfluxDB:
  class { '::collectd':
    purge        => true,
    recurse      => true,
    purge_config => true,
  }
  
  collectd::plugin { 'df': }
  collectd::plugin { 'disk': }
  collectd::plugin { 'entropy': }
  collectd::plugin { 'memory': }
  collectd::plugin { 'swap': }
  collectd::plugin { 'cpu': }
  collectd::plugin { 'cpufreq': }
  collectd::plugin { 'contextswitch': }
  collectd::plugin { 'processes': }
  collectd::plugin { 'vmem': }
  class { 'collectd::plugin::load':}
  
  #Write the collectd status to the Riemann VM in the Graphite format:
  class { 'collectd::plugin::write_graphite':
    graphitehost => 'dnsmetrics.local',
    protocol => 'tcp',
    graphiteport => 2003,
  }

  #Get network interface data:
  class { 'collectd::plugin::interface':
    interfaces     => ['lo', 'eth0', 'eth1'],
  }

  #BIND module is from: https://github.com/thias/puppet-bind
  include bind
  bind::server::conf { '/etc/named.conf':
    acls => {
      'rfc1918' => [ '10/8', '172.16/12', '192.168/16' ],
      'local'   => [ '127.0.0.1' ],
      '10net'   => [ '10.0.0.0/24', '10.0.1.0/24', '10.1.1.0/24', '10.1.0.0/24'],
    },
    directory => '/var/named',
    listen_on_addr    => [ '127.0.0.1' ],
    listen_on_v6_addr => [ '::1' ],
    forwarders        => [ '8.8.8.8', '8.8.4.4' ],
    allow_query       => [ 'localhost', 'local', '10net'],
    recursion         => 'no',
    allow_recursion   => [ 'localhost', 'local', '10net'],
    #Include some other zone files for localhost and loopback zones:
    includes => ['/etc/named.rfc1912.zones', '/etc/named.root.key'],
    zones => {
      #root hints zone
      '.' => [
        'type hint',
        'file "/var/named/named.ca"',
      ],
    'zone1.local' => [
      'type master',
      'file "zone1.local"',
      'allow-query { any; }',
      'allow-transfer { 10net; }',
      'allow-update { local; }',
      ],
    'zone2.local' => [
      'type master',
      'file "zone2.local"',
      'allow-query { any; }',
      'allow-transfer { 10net; }',
      'allow-update { local; }',
      ],
    'zone3.local' => [
      'type master',
      'file "zone3.local"',
      'allow-query { any; }',
      'allow-transfer { 10net; }',
      'allow-update { local; }',
      ],
    'zone4.local' => [
      'type master',
      'file "zone4.local"',
      'allow-query { any; }',
      'allow-transfer { 10net; }',
      'allow-update { local; }',
      ],
    'zone5.local' => [
      'type master',
      'file "zone5.local"',
      'allow-query { any; }',
      'allow-transfer { 10net; }',
      'allow-update { local; }',
      ],
    },
  }

  bind::server::file { 'zone1.local':
    source => 'puppet:///bind/zone_files/zone1.local.zone',
  }

  bind::server::file { 'zone2.local':
    source => 'puppet:///bind/zone_files/zone2.local.zone',
  }

  bind::server::file { 'zone3.local':
    source => 'puppet:///bind/zone_files/zone3.local.zone',
  }

  bind::server::file { 'zone4.local':
    source => 'puppet:///bind/zone_files/zone4.local.zone',
  }

  bind::server::file { 'zone5.local':
    source => 'puppet:///bind/zone_files/zone5.local.zone',
  }

  ###############################
  # Icinga 2 host export stuff
  ###############################

  @@icinga2::object::host { $::fqdn:
    display_name => $::fqdn,
    ipv4_address => $::ipaddress_eth1,
    groups => ['linux_servers', 'clients', 'ssh_servers', 'dns_servers'],
    vars => {
      os              => 'linux',
      virtual_machine => 'true',
      distro          => $::operatingsystem,
    },
    target_dir => '/etc/icinga2/objects/hosts',
    target_file_name => "${fqdn}.conf"
  }

 ###############################
  # NRPE installation/configuration
  ###############################

  class { 'icinga2::nrpe':
    nrpe_allowed_hosts => ['10.0.1.80', '127.0.0.1'],
    nrpe_listen_port => 5666,
  }

  #Some basic box health stuff
  icinga2::nrpe::command { 'check_users':
    nrpe_plugin_name => 'check_users',
    nrpe_plugin_args => '-w 5 -c 10',
  }
  
  #check_load
  icinga2::nrpe::command { 'check_load':
    nrpe_plugin_name => 'check_load',
    nrpe_plugin_args => '-w 50,40,30 -c 60,50,40',
  }
  
  #check_disk
  icinga2::nrpe::command { 'check_disk':
    nrpe_plugin_name => 'check_disk',
    nrpe_plugin_args => '-w 20% -c 10% -p /',
  }

  #check_total_procs  
  icinga2::nrpe::command { 'check_total_procs':
    nrpe_plugin_name => 'check_procs',
    nrpe_plugin_args => '-w 1000 -c 1500',
  }
 
  #check_zombie_procs
  icinga2::nrpe::command { 'check_zombie_procs':
    nrpe_plugin_name => 'check_procs',
    nrpe_plugin_args => '-w 5 -c 10 -s Z',
  }
  
  icinga2::nrpe::command { 'check_ntp_time':
    nrpe_plugin_name => 'check_ntp_time',
    nrpe_plugin_args => '-H 127.0.0.1',
  }
  
  #Create an NRPE command to monitor MySQL:
  icinga2::nrpe::command { 'check_mysql_service':
    nrpe_plugin_name => 'check_mysql',
    nrpe_plugin_args => '-H 127.0.0.1 -u root -p horsebatterystaple',
  }

}

node 'dnsslave1.local' {

  ###############################
  # SSH installation/setup
  ###############################

  #This module is from: https://github.com/saz/puppet-ssh
  class { 'ssh':
    #Export host keys to PuppetDB:
    storeconfigs_enabled => true,
    server_options => {
      #Whether to allow password auth; if set to 'no', only SSH keys can be used:
      #'PasswordAuthentication' => 'no',
      #How many authentication attempts to allow before disconnecting:
      'MaxAuthTries'         => '10',
      'PermitEmptyPasswords' => 'no', 
      'PermitRootLogin'      => 'no',
      'Port'                 => [22],
      'PubkeyAuthentication' => 'yes',
      #Whether to be strict about the permissions on a user's .ssh/ folder and public keys:
      'StrictModes'          => 'yes',
      'TCPKeepAlive'         => 'yes',
      #Whether to do reverse DNS lookups of client IP addresses when they connect:
      'UseDNS'               => 'no',
    },
  }

  ###############################
  # rsyslog installation/setup
  ###############################

  #This module is from: https://github.com/saz/puppet-rsyslog
  class { 'rsyslog::client':
    log_remote     => true,
    remote_type    => 'tcp',
    log_local      => true,
    log_auth_local => true,
    custom_config  => undef,
    server         => 'dnslogging.local',
    port           => '5514',
  }

  ###############################
  # NTP installation/setup
  ###############################

  #This module is: https://github.com/puppetlabs/puppetlabs-ntp
  class { '::ntp':
    servers  => [ '0.ubuntu.pool.ntp.org', '1.ubuntu.pool.ntp.org', '2.ubuntu.pool.ntp.org', '3.ubuntu.pool.ntp.org' ],
    restrict => ['127.0.0.1', '10.0.1.0 mask 255.255.255.0 kod notrap nomodify nopeer noquery'],
    disable_monitor => true,
  }

  #BIND module is from: https://github.com/thias/puppet-bind
  #Just install the BIND package:
  include bind::package

  ###############################
  # collectd installation/setup
  ###############################

  #Install Collectd so we can get metrics from this machine into Riemann/InfluxDB:
  class { '::collectd':
    purge        => true,
    recurse      => true,
    purge_config => true,
  }
  
  collectd::plugin { 'df': }
  collectd::plugin { 'disk': }
  collectd::plugin { 'entropy': }
  collectd::plugin { 'memory': }
  collectd::plugin { 'swap': }
  collectd::plugin { 'cpu': }
  collectd::plugin { 'cpufreq': }
  collectd::plugin { 'contextswitch': }
  collectd::plugin { 'processes': }
  collectd::plugin { 'vmem': }
  class { 'collectd::plugin::load':}
  
  #Write the collectd status to the Riemann VM in the Graphite format:
  class { 'collectd::plugin::write_graphite':
    graphitehost => 'dnsmetrics.local',
    protocol => 'tcp',
    graphiteport => 2003,
  }

  #Get network interface data:
  class { 'collectd::plugin::interface':
    interfaces     => ['lo', 'eth0', 'eth1'],
  }

  ###############################
  # Icinga 2 host export stuff
  ###############################

  @@icinga2::object::host { $::fqdn:
    display_name => $::fqdn,
    ipv4_address => $::ipaddress_eth1,
    groups => ['linux_servers', 'clients', 'ssh_servers', 'dns_servers'],
    vars => {
      os              => 'linux',
      virtual_machine => 'true',
      distro          => $::operatingsystem,
    },
    target_dir => '/etc/icinga2/objects/hosts',
    target_file_name => "${fqdn}.conf"
  }

 ###############################
  # NRPE installation/configuration
  ###############################

  class { 'icinga2::nrpe':
    nrpe_allowed_hosts => ['10.0.1.80', '127.0.0.1'],
    nrpe_listen_port => 5666,
  }

  #Some basic box health stuff
  icinga2::nrpe::command { 'check_users':
    nrpe_plugin_name => 'check_users',
    nrpe_plugin_args => '-w 5 -c 10',
  }
  
  #check_load
  icinga2::nrpe::command { 'check_load':
    nrpe_plugin_name => 'check_load',
    nrpe_plugin_args => '-w 50,40,30 -c 60,50,40',
  }
  
  #check_disk
  icinga2::nrpe::command { 'check_disk':
    nrpe_plugin_name => 'check_disk',
    nrpe_plugin_args => '-w 20% -c 10% -p /',
  }

  #check_total_procs  
  icinga2::nrpe::command { 'check_total_procs':
    nrpe_plugin_name => 'check_procs',
    nrpe_plugin_args => '-w 1000 -c 1500',
  }
 
  #check_zombie_procs
  icinga2::nrpe::command { 'check_zombie_procs':
    nrpe_plugin_name => 'check_procs',
    nrpe_plugin_args => '-w 5 -c 10 -s Z',
  }
  
  icinga2::nrpe::command { 'check_ntp_time':
    nrpe_plugin_name => 'check_ntp_time',
    nrpe_plugin_args => '-H 127.0.0.1',
  }
  
  #Create an NRPE command to monitor MySQL:
  icinga2::nrpe::command { 'check_mysql_service':
    nrpe_plugin_name => 'check_mysql',
    nrpe_plugin_args => '-H 127.0.0.1 -u root -p horsebatterystaple',
  }

}

node 'dnsslave2.local' {

  ###############################
  # SSH installation/setup
  ###############################

  #This module is from: https://github.com/saz/puppet-ssh
  class { 'ssh':
    #Export host keys to PuppetDB:
    storeconfigs_enabled => true,
    server_options => {
      #Whether to allow password auth; if set to 'no', only SSH keys can be used:
      #'PasswordAuthentication' => 'no',
      #How many authentication attempts to allow before disconnecting:
      'MaxAuthTries'         => '10',
      'PermitEmptyPasswords' => 'no', 
      'PermitRootLogin'      => 'no',
      'Port'                 => [22],
      'PubkeyAuthentication' => 'yes',
      #Whether to be strict about the permissions on a user's .ssh/ folder and public keys:
      'StrictModes'          => 'yes',
      'TCPKeepAlive'         => 'yes',
      #Whether to do reverse DNS lookups of client IP addresses when they connect:
      'UseDNS'               => 'no',
    },
  }

  ###############################
  # rsyslog installation/setup
  ###############################

  #This module is from: https://github.com/saz/puppet-rsyslog
  class { 'rsyslog::client':
    log_remote     => true,
    remote_type    => 'tcp',
    log_local      => true,
    log_auth_local => true,
    custom_config  => undef,
    server         => 'dnslogging.local',
    port           => '5514',
  }

  ###############################
  # NTP installation/setup
  ###############################

  #This module is: https://github.com/puppetlabs/puppetlabs-ntp
  class { '::ntp':
    servers  => [ '0.centos.pool.ntp.org', '1.centos.pool.ntp.org', '2.centos.pool.ntp.org', '3.centos.pool.ntp.org' ],
    restrict => ['127.0.0.1', '10.0.1.0 mask 255.255.255.0 kod notrap nomodify nopeer noquery'],
    disable_monitor => true,
  }

  #BIND module is from: https://github.com/thias/puppet-bind
  #Just install the BIND package:
  include bind::package

  ###############################
  # collectd installation/setup
  ###############################

  #Install Collectd so we can get metrics from this machine into Riemann/InfluxDB:
  class { '::collectd':
    purge        => true,
    recurse      => true,
    purge_config => true,
  }
  
  collectd::plugin { 'df': }
  collectd::plugin { 'disk': }
  collectd::plugin { 'entropy': }
  collectd::plugin { 'memory': }
  collectd::plugin { 'swap': }
  collectd::plugin { 'cpu': }
  collectd::plugin { 'cpufreq': }
  collectd::plugin { 'contextswitch': }
  collectd::plugin { 'processes': }
  collectd::plugin { 'vmem': }
  class { 'collectd::plugin::load':}
  
  #Write the collectd status to the Riemann VM in the Graphite format:
  class { 'collectd::plugin::write_graphite':
    graphitehost => 'dnsmetrics.local',
    protocol => 'tcp',
    graphiteport => 2003,
  }

  #Get network interface data:
  class { 'collectd::plugin::interface':
    interfaces     => ['lo', 'eth0', 'eth1'],
  }

  ###############################
  # Icinga 2 host export stuff
  ###############################

  @@icinga2::object::host { $::fqdn:
    display_name => $::fqdn,
    ipv4_address => $::ipaddress_eth1,
    groups => ['linux_servers', 'clients', 'ssh_servers', 'dns_servers'],
    vars => {
      os              => 'linux',
      virtual_machine => 'true',
      distro          => $::operatingsystem,
    },
    target_dir => '/etc/icinga2/objects/hosts',
    target_file_name => "${fqdn}.conf"
  }

 ###############################
  # NRPE installation/configuration
  ###############################

  class { 'icinga2::nrpe':
    nrpe_allowed_hosts => ['10.0.1.80', '127.0.0.1'],
    nrpe_listen_port => 5666,
  }

  #Some basic box health stuff
  icinga2::nrpe::command { 'check_users':
    nrpe_plugin_name => 'check_users',
    nrpe_plugin_args => '-w 5 -c 10',
  }
  
  #check_load
  icinga2::nrpe::command { 'check_load':
    nrpe_plugin_name => 'check_load',
    nrpe_plugin_args => '-w 50,40,30 -c 60,50,40',
  }
  
  #check_disk
  icinga2::nrpe::command { 'check_disk':
    nrpe_plugin_name => 'check_disk',
    nrpe_plugin_args => '-w 20% -c 10% -p /',
  }

  #check_total_procs  
  icinga2::nrpe::command { 'check_total_procs':
    nrpe_plugin_name => 'check_procs',
    nrpe_plugin_args => '-w 1000 -c 1500',
  }
 
  #check_zombie_procs
  icinga2::nrpe::command { 'check_zombie_procs':
    nrpe_plugin_name => 'check_procs',
    nrpe_plugin_args => '-w 5 -c 10 -s Z',
  }
  
  icinga2::nrpe::command { 'check_ntp_time':
    nrpe_plugin_name => 'check_ntp_time',
    nrpe_plugin_args => '-H 127.0.0.1',
  }
  
  #Create an NRPE command to monitor MySQL:
  icinga2::nrpe::command { 'check_mysql_service':
    nrpe_plugin_name => 'check_mysql',
    nrpe_plugin_args => '-H 127.0.0.1 -u root -p horsebatterystaple',
  }

}

node 'dnsclient1.local' {

  ###############################
  # SSH installation/setup
  ###############################

  #This module is from: https://github.com/saz/puppet-ssh
  class { 'ssh':
    #Export host keys to PuppetDB:
    storeconfigs_enabled => true,
    server_options => {
      #Whether to allow password auth; if set to 'no', only SSH keys can be used:
      #'PasswordAuthentication' => 'no',
      #How many authentication attempts to allow before disconnecting:
      'MaxAuthTries'         => '10',
      'PermitEmptyPasswords' => 'no', 
      'PermitRootLogin'      => 'no',
      'Port'                 => [22],
      'PubkeyAuthentication' => 'yes',
      #Whether to be strict about the permissions on a user's .ssh/ folder and public keys:
      'StrictModes'          => 'yes',
      'TCPKeepAlive'         => 'yes',
      #Whether to do reverse DNS lookups of client IP addresses when they connect:
      'UseDNS'               => 'no',
    },
  }

  ###############################
  # rsyslog installation/setup
  ###############################

  #This module is from: https://github.com/saz/puppet-rsyslog
  class { 'rsyslog::client':
    log_remote     => true,
    remote_type    => 'tcp',
    log_local      => true,
    log_auth_local => true,
    custom_config  => undef,
    server         => 'dnslogging.local',
    port           => '5514',
  }

  ###############################
  # NTP installation/setup
  ###############################

  #This module is: https://github.com/puppetlabs/puppetlabs-ntp
  class { '::ntp':
    servers  => [ '0.ubuntu.pool.ntp.org', '1.ubuntu.pool.ntp.org', '2.ubuntu.pool.ntp.org', '3.ubuntu.pool.ntp.org' ],
    restrict => ['127.0.0.1', '10.0.1.0 mask 255.255.255.0 kod notrap nomodify nopeer noquery'],
    disable_monitor => true,
  }

  ###############################
  # collectd installation/setup
  ###############################

  #Install Collectd so we can get metrics from this machine into Riemann/InfluxDB:
  class { '::collectd':
    purge        => true,
    recurse      => true,
    purge_config => true,
  }
  
  collectd::plugin { 'df': }
  collectd::plugin { 'disk': }
  collectd::plugin { 'entropy': }
  collectd::plugin { 'memory': }
  collectd::plugin { 'swap': }
  collectd::plugin { 'cpu': }
  collectd::plugin { 'cpufreq': }
  collectd::plugin { 'contextswitch': }
  collectd::plugin { 'processes': }
  collectd::plugin { 'vmem': }
  class { 'collectd::plugin::load':}
  
  #Write the collectd status to the Riemann VM in the Graphite format:
  class { 'collectd::plugin::write_graphite':
    graphitehost => 'dnsmetrics.local',
    protocol => 'tcp',
    graphiteport => 2003,
  }

  #Get network interface data:
  class { 'collectd::plugin::interface':
    interfaces     => ['lo', 'eth0', 'eth1'],
  }

  ###############################
  # Icinga 2 host export stuff
  ###############################

  @@icinga2::object::host { $::fqdn:
    display_name => $::fqdn,
    ipv4_address => $::ipaddress_eth1,
    groups => ['linux_servers', 'clients', 'ssh_servers'],
    vars => {
      os              => 'linux',
      virtual_machine => 'true',
      distro          => $::operatingsystem,
    },
    target_dir => '/etc/icinga2/objects/hosts',
    target_file_name => "${fqdn}.conf"
  }

 ###############################
  # NRPE installation/configuration
  ###############################

  class { 'icinga2::nrpe':
    nrpe_allowed_hosts => ['10.0.1.80', '127.0.0.1'],
    nrpe_listen_port => 5666,
  }

  #Some basic box health stuff
  icinga2::nrpe::command { 'check_users':
    nrpe_plugin_name => 'check_users',
    nrpe_plugin_args => '-w 5 -c 10',
  }
  
  #check_load
  icinga2::nrpe::command { 'check_load':
    nrpe_plugin_name => 'check_load',
    nrpe_plugin_args => '-w 50,40,30 -c 60,50,40',
  }
  
  #check_disk
  icinga2::nrpe::command { 'check_disk':
    nrpe_plugin_name => 'check_disk',
    nrpe_plugin_args => '-w 20% -c 10% -p /',
  }

  #check_total_procs  
  icinga2::nrpe::command { 'check_total_procs':
    nrpe_plugin_name => 'check_procs',
    nrpe_plugin_args => '-w 1000 -c 1500',
  }
 
  #check_zombie_procs
  icinga2::nrpe::command { 'check_zombie_procs':
    nrpe_plugin_name => 'check_procs',
    nrpe_plugin_args => '-w 5 -c 10 -s Z',
  }
  
  icinga2::nrpe::command { 'check_ntp_time':
    nrpe_plugin_name => 'check_ntp_time',
    nrpe_plugin_args => '-H 127.0.0.1',
  }
  
  #Create an NRPE command to monitor MySQL:
  icinga2::nrpe::command { 'check_mysql_service':
    nrpe_plugin_name => 'check_mysql',
    nrpe_plugin_args => '-H 127.0.0.1 -u root -p horsebatterystaple',
  }

}

node 'dnsclient2.local' {

  ###############################
  # SSH installation/setup
  ###############################

  #This module is from: https://github.com/saz/puppet-ssh
  class { 'ssh':
    #Export host keys to PuppetDB:
    storeconfigs_enabled => true,
    server_options => {
      #Whether to allow password auth; if set to 'no', only SSH keys can be used:
      #'PasswordAuthentication' => 'no',
      #How many authentication attempts to allow before disconnecting:
      'MaxAuthTries'         => '10',
      'PermitEmptyPasswords' => 'no', 
      'PermitRootLogin'      => 'no',
      'Port'                 => [22],
      'PubkeyAuthentication' => 'yes',
      #Whether to be strict about the permissions on a user's .ssh/ folder and public keys:
      'StrictModes'          => 'yes',
      'TCPKeepAlive'         => 'yes',
      #Whether to do reverse DNS lookups of client IP addresses when they connect:
      'UseDNS'               => 'no',
    },
  }

  ###############################
  # rsyslog installation/setup
  ###############################

  #This module is from: https://github.com/saz/puppet-rsyslog
  class { 'rsyslog::client':
    log_remote     => true,
    remote_type    => 'tcp',
    log_local      => true,
    log_auth_local => true,
    custom_config  => undef,
    server         => 'dnslogging.local',
    port           => '5514',
  }

  ###############################
  # NTP installation/setup
  ###############################

  #This module is: https://github.com/puppetlabs/puppetlabs-ntp
  class { '::ntp':
    servers  => [ '0.centos.pool.ntp.org', '1.centos.pool.ntp.org', '2.centos.pool.ntp.org', '3.centos.pool.ntp.org' ],
    restrict => ['127.0.0.1', '10.0.1.0 mask 255.255.255.0 kod notrap nomodify nopeer noquery'],
    disable_monitor => true,
  }

  ###############################
  # collectd installation/setup
  ###############################

  #Install Collectd so we can get metrics from this machine into Riemann/InfluxDB:
  class { '::collectd':
    purge        => true,
    recurse      => true,
    purge_config => true,
  }
  
  collectd::plugin { 'df': }
  collectd::plugin { 'disk': }
  collectd::plugin { 'entropy': }
  collectd::plugin { 'memory': }
  collectd::plugin { 'swap': }
  collectd::plugin { 'cpu': }
  collectd::plugin { 'cpufreq': }
  collectd::plugin { 'contextswitch': }
  collectd::plugin { 'processes': }
  collectd::plugin { 'vmem': }
  class { 'collectd::plugin::load':}
  
  #Write the collectd status to the Riemann VM in the Graphite format:
  class { 'collectd::plugin::write_graphite':
    graphitehost => 'dnsmetrics.local',
    protocol => 'tcp',
    graphiteport => 2003,
  }

  #Get network interface data:
  class { 'collectd::plugin::interface':
    interfaces     => ['lo', 'eth0', 'eth1'],
  }

  ###############################
  # Icinga 2 host export stuff
  ###############################

  @@icinga2::object::host { $::fqdn:
    display_name => $::fqdn,
    ipv4_address => $::ipaddress_eth1,
    groups => ['linux_servers', 'clients', 'ssh_servers'],
    vars => {
      os              => 'linux',
      virtual_machine => 'true',
      distro          => $::operatingsystem,
    },
    target_dir => '/etc/icinga2/objects/hosts',
    target_file_name => "${fqdn}.conf"
  }

 ###############################
  # NRPE installation/configuration
  ###############################

  class { 'icinga2::nrpe':
    nrpe_allowed_hosts => ['10.0.1.80', '127.0.0.1'],
    nrpe_listen_port => 5666,
  }

  #Some basic box health stuff
  icinga2::nrpe::command { 'check_users':
    nrpe_plugin_name => 'check_users',
    nrpe_plugin_args => '-w 5 -c 10',
  }
  
  #check_load
  icinga2::nrpe::command { 'check_load':
    nrpe_plugin_name => 'check_load',
    nrpe_plugin_args => '-w 50,40,30 -c 60,50,40',
  }
  
  #check_disk
  icinga2::nrpe::command { 'check_disk':
    nrpe_plugin_name => 'check_disk',
    nrpe_plugin_args => '-w 20% -c 10% -p /',
  }

  #check_total_procs  
  icinga2::nrpe::command { 'check_total_procs':
    nrpe_plugin_name => 'check_procs',
    nrpe_plugin_args => '-w 1000 -c 1500',
  }
 
  #check_zombie_procs
  icinga2::nrpe::command { 'check_zombie_procs':
    nrpe_plugin_name => 'check_procs',
    nrpe_plugin_args => '-w 5 -c 10 -s Z',
  }
  
  icinga2::nrpe::command { 'check_ntp_time':
    nrpe_plugin_name => 'check_ntp_time',
    nrpe_plugin_args => '-H 127.0.0.1',
  }
  
  #Create an NRPE command to monitor MySQL:
  icinga2::nrpe::command { 'check_mysql_service':
    nrpe_plugin_name => 'check_mysql',
    nrpe_plugin_args => '-H 127.0.0.1 -u root -p horsebatterystaple',
  }

}

node 'dnsmonitoring.local' {

  ###############################
  # SSH installation/setup
  ###############################

  #This module is from: https://github.com/saz/puppet-ssh
  class { 'ssh':
    #Export host keys to PuppetDB:
    storeconfigs_enabled => true,
    server_options => {
      #Whether to allow password auth; if set to 'no', only SSH keys can be used:
      #'PasswordAuthentication' => 'no',
      #How many authentication attempts to allow before disconnecting:
      'MaxAuthTries'         => '10',
      'PermitEmptyPasswords' => 'no', 
      'PermitRootLogin'      => 'no',
      'Port'                 => [22],
      'PubkeyAuthentication' => 'yes',
      #Whether to be strict about the permissions on a user's .ssh/ folder and public keys:
      'StrictModes'          => 'yes',
      'TCPKeepAlive'         => 'yes',
      #Whether to do reverse DNS lookups of client IP addresses when they connect:
      'UseDNS'               => 'no',
    },
  }

  ###############################
  # Postfix installation/setup
  ###############################

  #Install Postfix so we can monitor SMTP services and send out email alerts:
  class { '::postfix::server':
    inet_interfaces => 'all', #Listen on all interfaces
    inet_protocols => 'all', #Use both IPv4 and IPv6
    mydomain       => 'local',
    mynetworks => '127.0.0.0/8 [::ffff:127.0.0.0]/104 [::1]/128 10.0.1.0/24',
    extra_main_parameters => {
      'home_mailbox' => 'Maildir/',
      'mailbox_command' => '',
      'disable_dns_lookups' => 'yes' #Don't do DNS lookups for MX records since we're just using /etc/hosts for all host lookups
    }  
  }

  #Create a user account so we can test receiving mail:
  user { 'nick':
    ensure => present,
    home => '/home/nick',
    groups => ['sudo', 'admin'],
    #This is 'password', in salted SHA-512 form:
    password => '$6$IPYwCTfWyO$bIVTSw4ai/BGtZpfI4HtC8XE7bmb8b3kdZ6gRz4DF4hm7WmD35azXoFxN90TRrSYQdKo011YnBl7p3UXR2osQ1',
    shell => '/bin/bash',
  }

  file { '/home/nick' :
    ensure => directory,
    owner => 'nick',
    group => 'nick',
    mode =>  '755',
  }

  ###############################
  # Apache installation/setup
  ###############################

  #Install Apache so we can run Kibana:
  class{ '::apache':}
  ::apache::mod { 'ssl': }        #Install/enable the SSL module
  ::apache::mod { 'proxy': }      #Install/enable the proxy module
  ::apache::mod { 'proxy_http': } #Install/enable the HTTP proxy module
  ::apache::mod { 'rewrite': }    #Install/enable the rewrite module

  ###############################
  # Riemann installation/setup
  ###############################

  #Install Java so we can run Riemann; use the -> arrow so that it gets instaleld:
  package {'openjdk-7-jdk':
    ensure => installed,
  } ->

  class { 'riemann': 
    version => '0.2.6',
    riemann_config_source => 'puppet:///riemann/configs/riemann.config',
  }

  ###############################
  # InfluxDB installation/setup
  ###############################
  
  #Coming soon...

  ###############################
  # Grafana installation/setup
  ###############################

  #Create a folder where the SSL certificate and key will live:
  file {'/etc/apache2/ssl': 
    ensure => directory,
    owner => 'root',
    group => 'root',
    mode => '600',
  }

  #Create a sites/ folder for Apache to serve webapps out of:
  file {'/sites/': 
      ensure => directory,
      owner => 'www-data',
      group => 'www-data',
      mode => '755',
  }

  #Create an apps/ in /sites:
  file {'/sites/apps/': 
      ensure => directory,
      owner => 'www-data',
      group => 'www-data',
      mode => '755',
  }

  #A non-SSL virtual host for grafana:
  ::apache::vhost { 'grafana.dnsmetrics.local_non-ssl':
    port            => 80,
    docroot         => '/sites/apps/grafana',
    servername      => "grafana.${fqdn}",
    access_log => true,
    access_log_syslog=> 'syslog:local1',
    error_log => true,
    error_log_syslog=> 'syslog:local1',
    custom_fragment => '
      #Disable multiviews since they can have unpredictable results
      <Directory "/sites/apps/grafana">
        AllowOverride All
        Require all granted
        Options -Multiviews
      </Directory>
    ',
  }

  ###############################
  # rsyslog installation/setup
  ###############################

  #This module is from: https://github.com/saz/puppet-rsyslog
  class { 'rsyslog::client':
    #Write out logs in RFC3146 format so that they're more consistent when we send them to
    #Logstash. Logstash is set up to understand this format of logs in its config:
    log_templates => [
      { name => 'RFC3164fmt', template => '<%PRI%>%TIMESTAMP% %HOSTNAME% %syslogtag%%msg%',},
    ],
    log_remote     => true,
    server         => 'dnslogging.local',
    port           => '5514',
    remote_type    => 'tcp',
    log_local      => true,
    log_auth_local => true,
    custom_config  => undef,
  }

  #Make rsyslog watch the Apache log files:
  rsyslog::imfile { 'apache-access':
    file_name => '/var/log/apache2/access.log',
    file_tag => 'apache-access',
    file_facility => 'local7',
    file_severity => 'info',
  }

  rsyslog::imfile { 'apache-error':
    file_name => '/var/log/apache2/error.log',
    file_tag => 'apache-errors',
    file_facility => 'local7',
    file_severity => 'error',
  }

  ###############################
  # NTP installation/setup
  ###############################

  #This module is: https://github.com/puppetlabs/puppetlabs-ntp
  class { '::ntp':
    servers  => [ '0.ubuntu.pool.ntp.org', '1.ubuntu.pool.ntp.org', '2.ubuntu.pool.ntp.org', '3.ubuntu.pool.ntp.org' ],
    restrict => ['127.0.0.1', '10.0.1.0 mask 255.255.255.0 kod notrap nomodify nopeer noquery'],
    disable_monitor => true,
  }

  ###############################
  # Icinga 2 installation/setup
  ###############################
  
  #Install Postgres for use as a database with Icinga 2...
  class { 'postgresql::server': } ->

  #Create a Postgres DB for Icinga 2:
  postgresql::server::db { 'icinga2_data':
    user     => 'icinga2',
    password => postgresql_password('icinga2', 'password'),
    grant => 'all',
  } ->

  #Create a Postgres DB for Icinga Web 2:
  postgresql::server::db { 'icingaweb2_data':
    user     => 'icingaweb2',
    password => postgresql_password('icingaweb2', 'password'),
    grant => 'all',
  } ->

  #Install Icinga 2:
  class { 'icinga2::server': 
    server_db_type => 'pgsql',
    db_user        => 'icinga2',
    db_name        => 'icinga2_data',
    db_password    => 'password',
    db_host        => '127.0.0.1',
    db_port        => '5432',
    server_install_nagios_plugins => false,
    install_mail_utils_package => true,
    server_enabled_features  => ['checker','notification', 'livestatus', 'syslog'],
    server_disabled_features => ['graphite', 'api'],
  } ->

  #Collect all @@icinga2::object::host resources from PuppetDB that were exported by other machines:
  Icinga2::Object::Host <<| |>> { }

  #Create a linux_servers hostgroup:
  icinga2::object::hostgroup { 'linux_servers':
    display_name => 'Linux servers',
    #groups => ['mysql_servers', 'clients'],
    target_dir => '/etc/icinga2/objects/hostgroups',
    assign_where => 'match("*redis*", host.name) || match("*elastic*", host.name) || match("*logstash*", host.name)',
  }

  #Create a mysql_servers hostgroup:
  icinga2::object::hostgroup { 'mysql_servers':
    display_name => 'MySQL servers',
    target_dir => '/etc/icinga2/objects/hostgroups',
  }

  #Postgres IDO connection object:
  icinga2::object::idopgsqlconnection { 'testing_postgres':
     host             => '127.0.0.1',
     port             => 5432,
     user             => 'icinga2',
     password         => 'password',
     database         => 'icinga2_data',
     target_file_name => 'ido-pgsql.conf',
     target_dir       => '/etc/icinga2/features-enabled',
     categories       => ['DbCatConfig', 'DbCatState', 'DbCatAcknowledgement', 'DbCatComment', 'DbCatDowntime', 'DbCatEventHandler' ],
  }

  #Create a sysloglogger object:
  icinga2::object::sysloglogger { 'syslog-warning':
    severity => 'warning',
    target_dir => '/etc/icinga2/features-enabled',
  }

  #Create a user definition:
  icinga2::object::user { 'nick':
    display_name => 'Nick',
    email => 'nick@dnsmail.local',
    period => '24x7',
    enable_notifications => 'true',
    groups => [ 'admins' ],
    states => [ 'OK', 'Warning', 'Critical', 'Unknown', 'Up', 'Down' ],
    types => [ 'Problem', 'Recovery', 'Acknowledgement', 'Custom', 'DowntimeStart', 'DowntimeEnd', 'DowntimeRemoved', 'FlappingStart', 'FlappingEnd' ],
    target_dir => '/etc/icinga2/objects/users',
  }

  #Create an admins user group:
  icinga2::object::usergroup { 'admins':
    display_name => 'admins',
    target_dir => '/etc/icinga2/objects/usergroups',
  }

  #Create a DNS servers hostgroup:
  icinga2::object::hostgroup { 'dns_servers':
    display_name => 'DNS servers',
    target_dir => '/etc/icinga2/objects/hostgroups',
  }

  #Create a postgres_servers hostgroup:
  icinga2::object::hostgroup { 'postgres_servers':
    display_name => 'Postgres servers',
    target_dir => '/etc/icinga2/objects/hostgroups',
  }

  #Create an IMAP servers hostgroup:
  icinga2::object::hostgroup { 'imap_servers':
    display_name => 'IMAP servers',
    target_dir => '/etc/icinga2/objects/hostgroups',
  }

  #Create an HTTP servers hostgroup:
  icinga2::object::hostgroup { 'http_servers':
    display_name => 'HTTP servers',
    target_dir => '/etc/icinga2/objects/hostgroups',
  }

  #Create an SSH servers hostgroup:
  icinga2::object::hostgroup { 'ssh_servers':
    display_name => 'SSH servers',
    target_dir => '/etc/icinga2/objects/hostgroups',
  }

  #Create a clients hostgroup:
  icinga2::object::hostgroup { 'clients':
    display_name => 'Client machines',
    target_dir => '/etc/icinga2/objects/hostgroups',
  }

  #Create an SMTP servers hostgroup
  icinga2::object::hostgroup { 'smtp_servers':
    display_name => 'SMTP servers',
    target_dir => '/etc/icinga2/objects/hostgroups',
  }

  #Create a web services servicegroup:
  icinga2::object::servicegroup { 'web_services':
    display_name => 'web services',
    target_dir => '/etc/icinga2/objects/servicegroups',
  }

  #Create a database services servicegroup:
  icinga2::object::servicegroup { 'database_services':
    display_name => 'database services',
    target_dir => '/etc/icinga2/objects/servicegroups',
  }
  
  #Create an email services servicegroup:
  icinga2::object::servicegroup { 'email_services':
    display_name => 'email services',
    target_dir => '/etc/icinga2/objects/servicegroups',
  }

  #Create a machine health services servicegroup:
  icinga2::object::servicegroup { 'machine_health':
    display_name => 'machine health',
    target_dir => '/etc/icinga2/objects/servicegroups',
  }

  #Create an apply that checks SSH:
  icinga2::object::apply_service_to_host { 'check_ssh':
    display_name => 'SSH',
    check_command => 'ssh',
    vars => {
      service_type => 'production',
    },
    assign_where => '"ssh_servers" in host.groups',
    ignore_where => 'host.name == "localhost"',
    target_dir => '/etc/icinga2/objects/applys'
  }

  #Create an apply that checks SMTP:
  icinga2::object::apply_service_to_host { 'check_smtp':
    display_name => 'SMTP',
    check_command => 'smtp',
    vars => {
      service_type => 'production',
    },
    assign_where => '"smtp_servers" in host.groups',
    ignore_where => 'host.name == "localhost"',
    target_dir => '/etc/icinga2/objects/applys'
  }

  #Create an apply that checks load average:
  icinga2::object::apply_service_to_host { 'load_average':
    display_name => 'Load average',
    check_command => 'nrpe',
    vars => {
      service_type => 'production',
      nrpe_command => 'check_load',
    },
    assign_where => '"linux_servers" in host.groups',
    ignore_where => 'host.name == "localhost"',
    target_dir => '/etc/icinga2/objects/applys'
  }

  #Create an apply that checks the number of users:
  icinga2::object::apply_service_to_host { 'check_users':
    display_name => 'Logged in users',
    check_command => 'nrpe',
    vars => {
      service_type => 'production',
      nrpe_command => 'check_users',
    },
    assign_where => '"linux_servers" in host.groups',
    ignore_where => 'host.name == "localhost"',
    target_dir => '/etc/icinga2/objects/applys'
  }

  #Create an apply that checks disk space on /:
  icinga2::object::apply_service_to_host { 'check_disk':
    display_name => 'Disk space on /',
    check_command => 'nrpe',
    vars => {
      service_type => 'production',
      nrpe_command => 'check_disk',
    },
    assign_where => '"linux_servers" in host.groups',
    ignore_where => 'host.name == "localhost"',
    target_dir => '/etc/icinga2/objects/applys'
  }

  #Create an apply that checks the number of total processes:
  icinga2::object::apply_service_to_host { 'check_total_procs':
    display_name => 'Total procs',
    check_command => 'nrpe',
    vars => {
      service_type => 'production',
      nrpe_command => 'check_total_procs',
    },
    assign_where => '"linux_servers" in host.groups',
    ignore_where => 'host.name == "localhost"',
    target_dir => '/etc/icinga2/objects/applys'
  }

  #Create an apply that checks the number of zombie processes:
  icinga2::object::apply_service_to_host { 'check_zombie_procs':
    display_name => 'Zombie procs',
    check_command => 'nrpe',
    vars => {
      service_type => 'production',
      nrpe_command => 'check_zombie_procs',
    },
    assign_where => '"linux_servers" in host.groups',
    ignore_where => 'host.name == "localhost"',
    target_dir => '/etc/icinga2/objects/applys'
  }

  #Create an apply that checks MySQL:
  icinga2::object::apply_service_to_host { 'check_mysql_service':
    display_name => 'MySQL',
    check_command => 'nrpe',
    vars => {
      service_type => 'production',
      nrpe_command => 'check_mysql_service',
    },
    assign_where => '"mysql_servers" in host.groups',
    ignore_where => 'host.name == "localhost"',
    target_dir => '/etc/icinga2/objects/applys'
  }

  class { 'icinga2::nrpe':
    nrpe_allowed_hosts => ['10.0.1.80', '127.0.0.1'],
  }

  #Some basic box health stuff
  icinga2::nrpe::command { 'check_users':
    nrpe_plugin_name => 'check_users',
    nrpe_plugin_args => '-w 5 -c 10',
  }
  
  #check_load
  icinga2::nrpe::command { 'check_load':
    nrpe_plugin_name => 'check_load',
    nrpe_plugin_args => '-w 50,40,30 -c 60,50,40',
  }
  
  #check_disk
  icinga2::nrpe::command { 'check_disk':
    nrpe_plugin_name => 'check_disk',
    nrpe_plugin_args => '-w 20% -c 10% -p /',
  }

  #check_total_procs  
  icinga2::nrpe::command { 'check_total_procs':
    nrpe_plugin_name => 'check_procs',
    nrpe_plugin_args => '-w 1000 -c 1500',
  }
  
  #check_zombie_procs
  icinga2::nrpe::command { 'check_zombie_procs':
    nrpe_plugin_name => 'check_procs',
    nrpe_plugin_args => '-w 5 -c 10 -s Z',
  }
  
  icinga2::nrpe::command { 'check_ntp_time':
    nrpe_plugin_name => 'check_ntp_time',
    nrpe_plugin_args => '-H 127.0.0.1',
  }
  
  #Create an NRPE command to monitor MySQL:
  icinga2::nrpe::command { 'check_mysql_service':
    nrpe_plugin_name => 'check_mysql',
    nrpe_plugin_args => '-H 127.0.0.1 -u root -p horsebatterystaple',
  }

  ###############################
  # Icinga 2 host export stuff
  ###############################

  @@icinga2::object::host { $::fqdn:
    display_name => $::fqdn,
    ipv4_address => $::ipaddress_eth1,
    groups => ['linux_servers', 'clients', 'ssh_servers', 'smtp_servers', 'http_servers', 'postgres_servers'],
    vars => {
      os              => 'linux',
      virtual_machine => 'true',
      distro          => $::operatingsystem,
    },
    target_dir => '/etc/icinga2/objects/hosts',
    target_file_name => "${fqdn}.conf"
  }

  ###############################
  # collectd installation/setup
  ###############################

  #Install Collectd so we can get metrics from this machine into Riemann/InfluxDB:
  class { '::collectd':
    purge        => true,
    recurse      => true,
    purge_config => true,
  }
  
  collectd::plugin { 'df': }
  collectd::plugin { 'disk': }
  collectd::plugin { 'entropy': }
  collectd::plugin { 'memory': }
  collectd::plugin { 'swap': }
  collectd::plugin { 'cpu': }
  collectd::plugin { 'cpufreq': }
  collectd::plugin { 'contextswitch': }
  collectd::plugin { 'processes': }
  collectd::plugin { 'vmem': }
  class { 'collectd::plugin::load':}
  
  #Write the collectd status to the Riemann VM in the Graphite format:
  class { 'collectd::plugin::write_graphite':
    graphitehost => 'dnsmetrics.local',
    protocol => 'tcp',
    graphiteport => 2003,
  }

  #Get network interface data:
  class { 'collectd::plugin::interface':
    interfaces     => ['lo', 'eth0', 'eth1'],
  }

}