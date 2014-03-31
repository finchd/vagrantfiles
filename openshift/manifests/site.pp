#default node defition
node default {

  #This module is from: https://github.com/saz/puppet-ssh
  include ssh

}


#Puppet master node definition
node 'openshiftmaster.local' {

  class { 'puppetdb':
    listen_address => '0.0.0.0'
  }
  
  include puppetdb::master::config
 
  #This module is from: https://github.com/saz/puppet-rsyslog
  class { 'rsyslog::server': }
 
}

#CentOS OpenShift broker node
node 'broker.local' {

  #This module is from: https://github.com/saz/puppet-ssh
  include ssh

  #This module is from: https://github.com/saz/puppet-rsyslog
  class { 'rsyslog::client':
    log_remote     => true,
    remote_type    => 'tcp',
    log_local      => true,
    log_auth_local => true,
    custom_config  => undef,
    server         => 'openshiftmaster.local',
    port           => '514',
  }
  
  #This module is: https://github.com/puppetlabs/puppetlabs-ntp
  class { '::ntp':
    servers => [ '0.pool.ntp.org', '1.pool.ntp.org', '2.pool.ntp.org', '3.pool.ntp.org' ],
    restrict => ['default kod nomodify notrap nopeer noquery', '-6 default kod nomodify notrap nopeer noquery', '127.0.0.1', '-6 ::1'],
  }

}

#CentOS OpenShift ActiveMQ server
node 'activemq.local' {

  #This module is from: https://github.com/saz/puppet-ssh
  include ssh

  #This module is from: https://github.com/saz/puppet-rsyslog
  class { 'rsyslog::client':
    log_remote     => true,
    remote_type    => 'tcp',
    log_local      => true,
    log_auth_local => true,
    custom_config  => undef,
    server         => 'openshiftmaster.local',
    port           => '514',
  }

}

#CentOS OpenShift MongoDB server
node 'mongodb.local' {

  #This module is from: https://github.com/saz/puppet-ssh
  include ssh

  #This module is from: https://github.com/saz/puppet-rsyslog
  class { 'rsyslog::client':
    log_remote     => true,
    remote_type    => 'tcp',
    log_local      => true,
    log_auth_local => true,
    custom_config  => undef,
    server         => 'openshiftmaster.local',
    port           => '514',
  }

}

#CentOS OpenShift node
node 'node1.local' {

  #This module is from: https://github.com/saz/puppet-ssh
  include ssh

  #This module is from: https://github.com/saz/puppet-rsyslog
  class { 'rsyslog::client':
    log_remote     => true,
    remote_type    => 'tcp',
    log_local      => true,
    log_auth_local => true,
    custom_config  => undef,
    server         => 'openshiftmaster.local',
    port           => '514',
  }

}

#CentOS OpenShift node
node 'node2.local' {

  #This module is from: https://github.com/saz/puppet-ssh
  include ssh

  #This module is from: https://github.com/saz/puppet-rsyslog
  class { 'rsyslog::client':
    log_remote     => true,
    remote_type    => 'tcp',
    log_local      => true,
    log_auth_local => true,
    custom_config  => undef,
    server         => 'openshiftmaster.local',
    port           => '514',
  }

}

#CentOS OpenShift node
node 'node3.local' {


  #This module is from: https://github.com/saz/puppet-ssh
  include ssh

  #This module is from: https://github.com/saz/puppet-rsyslog
  class { 'rsyslog::client':
    log_remote     => true,
    remote_type    => 'tcp',
    log_local      => true,
    log_auth_local => true,
    custom_config  => undef,
    server         => 'openshiftmaster.local',
    port           => '514',
  }

}

#CentOS OpenShift node
node 'node4.local' {

  #This module is from: https://github.com/saz/puppet-ssh
  include ssh

  #This module is from: https://github.com/saz/puppet-rsyslog
  class { 'rsyslog::client':
    log_remote     => true,
    remote_type    => 'tcp',
    log_local      => true,
    log_auth_local => true,
    custom_config  => undef,
    server         => 'openshiftmaster.local',
    port           => '514',
  }

}