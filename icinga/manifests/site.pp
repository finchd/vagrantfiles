#default node defition
node default {

  include ssh

}

#puppet master node definition
node 'icingamaster.local' {

  class { 'puppetdb':
    listen_address => '0.0.0.0'
  }
  
 include puppetdb::master::config

}

#Ubuntu Icinga server node

node 'ubuntuicinga.local' {

  class { 'postgresql::server': }

}