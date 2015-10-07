class profile::haproxy_node {
  

}

class profile::haproxy_node::logging {

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
