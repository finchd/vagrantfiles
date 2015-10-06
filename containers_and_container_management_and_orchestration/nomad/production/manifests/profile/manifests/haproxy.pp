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
    ports     => '9090',
    options   => {
      'mode'  => 'http',
      'stats' => [
        'uri /',
      ],
    },
  }

}

class profile::haproxy::logging {

  heka::plugin::input::udpinput { 'haproxy_udp_input_2514':
    decoder  => "haproxy_log_decoder",
    splitter => "null_splitter",
    address  => "127.0.0.1:2514",
    net      => "udp4",
    notify   => Service['heka'],
  }

  file { '/usr/share/heka/lua_modules/haproxy_http_log.lua':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    source  => 'puppet:///files/heka/haproxy_http_log.lua',
  } ~>

  heka::plugin { 'haproxy_log_decoder':
    type => 'SandboxDecoder',
    settings => {
      module_directory => "'/usr/share/heka/lua_modules'",
      filename         => "'/usr/share/heka/lua_modules/haproxy_http_log.lua'",
      script_type      => "'lua'",
    },
    subsetting_sections => {
      config => {
        'type'    => "'haproxy'",
        payload_keep => 'true',
      }
    },
    notify   => Service['heka'],
  }

}

class profile::haproxy::logging::elasticsearch_export {

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
      'message_matcher' => "\"Type == 'haproxy'\"",
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