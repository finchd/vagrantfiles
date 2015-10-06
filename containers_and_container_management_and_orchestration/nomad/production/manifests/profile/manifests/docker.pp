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

class profile::docker::logging {

  #Gather Docker logs with Heka:
  heka::plugin {'docker_log_input':
    type     => 'DockerLogInput',
    notify => Service['heka'],
  }

  #Gather Docker events too:
  heka::plugin { 'docker_event_input':
    type   => 'DockerEventInput',
    notify => Service['heka'],
  }

  #Docker log/event Elasticsearch encoding and output:
  #The encoder:
  ::heka::plugin { 'elasticsearch_logstash_v0_encoder':
    type => 'ESLogstashV0Encoder',
    settings => {
    'es_index_from_timestamp' => 'true',
    'type_name' => '"%{Type}"',
    },
    notify => Service['heka'],
  }
  #The output which uses the encoder:
  ::heka::plugin { 'elasticsearch_output_1':
    type => 'ElasticSearchOutput',
    settings => {
      'message_matcher' => "\"Type == 'DockerEvent' || Type == 'DockerLog'\"",
      'server' => '"http://nomadmonitoring.local:9200"',
      'flush_interval' => '5000',
      'flush_count' => '10',
      'encoder' => '"elasticsearch_logstash_v0_encoder"',
    },
    subsetting_sections => {
      buffering => {
        #256MB, in bytes:
        max_file_size   => '268435456',
        #1GB, in bytes:
        max_buffer_size => '1073741824',
      }
    },
    notify => Service['heka'],
  }

}