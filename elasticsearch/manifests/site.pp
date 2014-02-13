#default node defition
node default {

}

#Puppet master node definition
node 'elasticsearchmaster.local' {

  class { 'puppetdb':
    listen_address => '0.0.0.0'
  }
  
  include puppetdb::master::config

  include ssh
  
  class { 'rsyslog::server': }
 
}

#Ubuntu ElasticSearch node
node 'elasticsearch1.local' {

  include ssh

  class { 'rsyslog::client':
    log_remote     => true,
    remote_type    => 'tcp',
    log_local      => true,
    log_auth_local => true,
    custom_config  => undef,
    server         => 'elasticsearchmaster.local',
    port           => '514',
  }

}

#Ubuntu ElasticSearch node
node 'elasticsearch2.local' {

  include ssh

  class { 'rsyslog::client':
    log_remote     => true,
    remote_type    => 'tcp',
    log_local      => true,
    log_auth_local => true,
    custom_config  => undef,
    server         => 'elasticsearchmaster.local',
    port           => '514',
  }

}

#Ubuntu ElasticSearch node
node 'elasticsearch3.local' {

  include ssh

  class { 'rsyslog::client':
    log_remote     => true,
    remote_type    => 'tcp',
    log_local      => true,
    log_auth_local => true,
    custom_config  => undef,
    server         => 'elasticsearchmaster.local',
    port           => '514',
  }

}

#Ubuntu ElasticSearch node
node 'elasticsearch4.local' {

  include ssh

  class { 'rsyslog::client':
    log_remote     => true,
    remote_type    => 'tcp',
    log_local      => true,
    log_auth_local => true,
    custom_config  => undef,
    server         => 'elasticsearchmaster.local',
    port           => '514',
  }

}

#Ubuntu ElasticSearch node
node 'elasticsearch5.local' {

  include ssh

  class { 'rsyslog::client':
    log_remote     => true,
    remote_type    => 'tcp',
    log_local      => true,
    log_auth_local => true,
    custom_config  => undef,
    server         => 'elasticsearchmaster.local',
    port           => '514',
  }

}

#Ubuntu ElasticSearch node
node 'elasticsearch6.local' {

  include ssh

  class { 'rsyslog::client':
    log_remote     => true,
    remote_type    => 'tcp',
    log_local      => true,
    log_auth_local => true,
    custom_config  => undef,
    server         => 'elasticsearchmaster.local',
    port           => '514',
  }

}