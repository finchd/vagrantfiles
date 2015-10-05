class profile::docker {

  #Add Docker's own Yum repo:
  case $::osfamily {
    'RedHat': {
      yumrepo { 'dockerrepo':
        descr    => 'Docker Repository',
        baseurl  => "https://yum.dockerproject.org/repo/main/centos/7",
        gpgcheck => 1,
        gpgkey   => 'https://yum.dockerproject.org/gpg',
        enabled  => 1,
      }   
    }   
  }

  class { 'docker':
    version => '1.8.2',
    package_name => 'docker-engine',
    storage_driver => 'btrfs',
    extra_parameters => '--graph /data',
  } ~>
  file { '/usr/lib/systemd/system/docker.service':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    source => 'puppet:///files/docker/docker.service',
    #notify  => Service['docker'],
  } ~>
  exec { 'systemd_reload_docker_unit_file':
    user        => 'root',
    command     => '/usr/bin/systemctl daemon-reload',
    refreshonly => true,
  } ~>
  exec { 'systemd_restart_docker':
    user        => 'root',
    command     => '/usr/bin/systemctl restart docker.service',
    refreshonly => true,
  }
}