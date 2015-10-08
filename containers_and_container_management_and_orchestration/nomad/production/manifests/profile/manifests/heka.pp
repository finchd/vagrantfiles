class profile::heka {

  ###############################
  # Heka installation/setup
  ###############################

  class { '::heka':
    package_download_url => hiera('heka_package_url'),
    version => hiera('heka_version'),
    heka_max_procs       => inline_template('<%= (@processorcount.to_f / 6).ceil %>'),
    purge_unmanaged_configs => true,
    cgroup_memory_limit  => '200M',
    global_config_settings => {
      'poolsize' => 100,
      'hostname' => "\"${::fqdn}\"",
    },
    systemd_unit_file_settings => {
      'RestartSec' => '30',
    },
  }

  ###############################
  # Splitter definitions
  ###############################

  #Define some splitters that we can use in other plugins:

  ::heka::plugin { 'newline_splitter':
    type => 'TokenSplitter',
    settings => {
      'delimiter' => '"\n"',
    },
  }

  ::heka::plugin { 'space_splitter':
    type => 'TokenSplitter',
    settings => {
      'delimiter' => '" "',
    },
  }

  heka::plugin { 'null_splitter':
    type   => 'NullSplitter',
  }

  ###############################
  # Input definitions
  ###############################

  #Define some inputs:

  ::heka::plugin::input::tcpinput { 'tcpinput1':
    address => "${::ipaddress_lo}:5565"
  }

  ::heka::plugin::input::udpinput { 'udpinput1':
    address => "${::ipaddress_lo}:4880"
  }

  #Start up a StatsD server:
  ::heka::plugin::input::statsdinput { 'statsdinput1':
   address => '0.0.0.0:8125',
   stat_accum_name => 'stataccuminput1',
  }

  ::heka::plugin::input::stataccuminput { 'stataccuminput1':
    ticker_interval => 1,
    emit_in_fields => true,
  }

  ###############################
  # Output definitions
  ###############################

  #Define some outputs that we can use in other plugins:

  #Output to Heka's standard out all messages going through the message router
  #Output them in RST format with the rstencoder defined above.
  #See the following page for more info on message_matcher syntax:
  # https://hekad.readthedocs.org/en/latest/message_matcher.html#message-matcher
  ::heka::plugin { 'logoutput1':
    type => 'LogOutput',
    settings => {
      'message_matcher' => "\"Type != 'heka.statmetric' && Type != 'heka.all-report' && Type != 'heka.memstat'\"",
      'encoder' => '"rstencoder"',
    },
  }

  #Start a dashboard:
  ::heka::plugin { 'dashboard1':
    type => 'DashboardOutput',
    settings => {
      'address' => '"0.0.0.0:4352"',
      'ticker_interval' => 6,
    },
  }

  ###############################
  # Encoder definitions
  ###############################

  #Define some encoders that we can use in other plugins:

  #Turn Heka messages into Restructured text:
  ::heka::plugin { 'rstencoder':
    type => 'RstEncoder',
  }
  
}

class profile::heka::elasticsearch_output {

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
      'message_matcher' => "\"Type == 'haproxy' || Type == 'DockerEvent' || Type == 'DockerLog' || Type == 'bind_query'\"",
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
