#A base HAProxy class that installs HAProxy and nothing else
class profile::haproxy {
  
  class { 'haproxy':
    global_options   => {
      'log'     => "${::ipaddress}:2514 local0",
      'chroot'  => '/var/lib/haproxy',
      'pidfile' => '/var/run/haproxy.pid',
      'maxconn' => '4000',
      'user'    => 'haproxy',
      'group'   => 'haproxy',
      'daemon'  => '',
      'stats'   => 'socket /var/lib/haproxy/stats',
    },
    defaults_options => {
      'log'     => 'global',
      'stats'   => 'enable',
      'option'  => 'redispatch',
      'retries' => '3',
      'timeout' => [
        'http-request 10s',
        'queue 1m',
        'connect 10s',
        'client 1m',
        'server 1m',
        'check 10s',
      ],
      'maxconn' => '10000',
    },
  }

  #HAProxy stats page:
  haproxy::listen { 'stats':
    ipaddress => '*',
    ports     => '9500',
    options   => {
      'mode'  => 'http',
      'stats' => [
        'uri /',
      ],
    },
  }

}