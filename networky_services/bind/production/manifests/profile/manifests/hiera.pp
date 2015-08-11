#This profile manages the hiera.yaml file and /etc/puppet/hieradata/ directory on Puppet masters:

class profile::hiera {

  class { '::hiera':
    datadir        => '/etc/puppetlabs/code/environments/%{::environment}/hieradata/yaml',
    datadir_manage => false,
    hierarchy      => [
      'node/%{fqdn}',
      'operatingsystem/%{operatingsystem}/%{operatingsystemmajrelease}',
      'operatingsystem/%{operatingsystem}',
      'osfamily/%{osfamily}',
      'common',
    ],
  }

}
