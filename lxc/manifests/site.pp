node 'lxcmaster.local' {

  class { 'puppetdb':
    listen_address => '0.0.0.0'
  }

  include puppetdb::master::config
	
} 