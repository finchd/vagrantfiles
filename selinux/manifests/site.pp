#default node defition
node default {

}

#Puppet master node definition
node 'selinuxmaster.local' {

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

  #This module is from: https://github.com/saz/puppet-ssh
  include ssh
  
  #This module is from: https://github.com/saz/puppet-rsyslog
  class { 'rsyslog::server':
    enable_tcp => true,
    enable_udp => true,
    port       => '514',
    server_dir => '/var/log/remote/',
  }
 
}

#Ubuntu ElasticSearch node
node 'selinux1.local' {

  #This module is from: https://github.com/saz/puppet-ssh
  include ssh

  #This module is from: https://github.com/saz/puppet-rsyslog
  class { 'rsyslog::client':
    log_remote     => true,
    remote_type    => 'tcp',
    log_local      => true,
    log_auth_local => true,
    custom_config  => undef,
    server         => 'selinuxmaster.local',
    port           => '514',
  }

  class { 'selinux':
    mode => 'permissive'
  }
  
  package { 'smartmontools':
    ensure => installed,
  }
}

#Ubuntu ElasticSearch node
node 'selinux2.local' {

  #This module is from: https://github.com/saz/puppet-ssh
  include ssh

  #This module is from: https://github.com/saz/puppet-rsyslog
  class { 'rsyslog::client':
    log_remote     => true,
    remote_type    => 'tcp',
    log_local      => true,
    log_auth_local => true,
    custom_config  => undef,
    server         => 'selinuxmaster.local',
    port           => '514',
  }

  class { 'selinux':
    mode => 'permissive'
  }

  package { 'smartmontools':
    ensure => installed,
  }

}

#Ubuntu ElasticSearch node
node 'selinux3.local' {

  #This module is from: https://github.com/saz/puppet-ssh
  include ssh

  #This module is from: https://github.com/saz/puppet-rsyslog
  class { 'rsyslog::client':
    log_remote     => true,
    remote_type    => 'tcp',
    log_local      => true,
    log_auth_local => true,
    custom_config  => undef,
    server         => 'selinuxmaster.local',
    port           => '514',
  }

  class { 'selinux':
    mode => 'permissive'
  }

  package { 'smartmontools':
    ensure => installed,
  }

}

#Ubuntu ElasticSearch node
node 'selinux4.local' {

  #This module is from: https://github.com/saz/puppet-ssh
  include ssh

  #This module is from: https://github.com/saz/puppet-rsyslog
  class { 'rsyslog::client':
    log_remote     => true,
    remote_type    => 'tcp',
    log_local      => true,
    log_auth_local => true,
    custom_config  => undef,
    server         => 'selinuxmaster.local',
    port           => '514',
  }

  class { 'selinux':
    mode => 'permissive'
  }

  package { 'smartmontools':
    ensure => installed,
  }

}