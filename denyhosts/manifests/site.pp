#default node defition
node default {

}

#puppet master node definition
node 'denymaster.local' {

  class { 'puppetdb':
    listen_address => '0.0.0.0'
  }
  
  include puppetdb::master::config
 
#  class { 'rsyslog::server': }

#  class { '::ntp':
#    servers  => [ '0.ubuntu.pool.node.org', '1.ubuntu.pool.node.org', '2.ubuntu.pool.node.org', '3.ubuntu.pool.node.org' ],
#    restrict => ['127.0.0.1', '10.0.1.0 mask 255.255.255.0 kod notrap nomodify nopeer noquery'],
#    disable_monitor => true,
#  }

}

node 'denyclient1.local' {
  #grab data from hiera
  #$message = hiera(allowed_hosts)
  
  #take the values retrieved from hiera and put newlines between them
  #$print_message = inline_template('<%= message.join("\n") %>')
  #notify {"${print_message}":}
  
  #include denyhosts

  include ssh

  class { 'rsyslog::client':
    log_remote     => true,
    remote_type    => 'tcp',
    log_local      => true,
    log_auth_local => true,
    custom_config  => undef,
    server         => 'denymaster.local',
    port           => '514',
  }

  class { '::ntp':
    servers  => [ '0.ubuntu.pool.node.org', '1.ubuntu.pool.node.org', '2.ubuntu.pool.node.org', '3.ubuntu.pool.node.org' ],
    restrict => ['127.0.0.1', '10.0.1.0 mask 255.255.255.0 kod notrap nomodify nopeer noquery'],
    disable_monitor => true,
  }


}

node 'denyclient2.local' {
  #grab data from hiera
  #$message = hiera(allowed_hosts)
  
  #take the values retrieved from hiera and put newlines between them
  #$print_message = inline_template('<%= message.join("\n") %>')
  #notify {"${print_message}":}
  
  #include denyhosts

  include ssh

  class { 'rsyslog::client':
    log_remote     => true,
    remote_type    => 'tcp',
    log_local      => true,
    log_auth_local => true,
    custom_config  => undef,
    server         => 'denymaster.local',
    port           => '514',
  }

  class { '::ntp':
    servers  => [ '0.ubuntu.pool.node.org', '1.ubuntu.pool.node.org', '2.ubuntu.pool.node.org', '3.ubuntu.pool.node.org' ],
    restrict => ['127.0.0.1', '10.0.1.0 mask 255.255.255.0 kod notrap nomodify nopeer noquery'],
    disable_monitor => true,
  }
}