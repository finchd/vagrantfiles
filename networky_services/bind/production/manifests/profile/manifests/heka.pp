class profile::heka {

  ###############################
  # Heka installation/setup
  ###############################

  class { '::heka':
    package_download_url => hiera('heka_package_url'),
    version => hiera('heka_version'),
    heka_max_procs         => 4,
    purge_unmanaged_configs => true,
    global_config_settings => {
      'poolsize' => 100,
      'hostname' => "\"${::fqdn}\"",
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

  ###############################
  # Other plugin definitions
  ###############################

  #Check that will pass with an OK:
  ::heka::plugin { 'check_procs_ok':
    type => 'ProcessInput',
    settings => {
      'ticker_interval' => '10',
      'splitter' => '"newline_splitter"',
      'stdout' => 'true',
      'stderr' => 'true',
    },
    subsetting_sections => {
      'command.0' => {
        'bin' => '"/usr/lib64/nagios/plugins/check_procs"',
      },
    }
  }

  #Check that will pass with a WARNING:
  #/usr/lib64/nagios/plugins/check_procs -w 1:1 -c 4 -C sshd
  ::heka::plugin { 'check_procs_warning':
    type => 'ProcessInput',
    settings => {
      'ticker_interval' => '10',
      'splitter' => '"newline_splitter"',
      'stdout' => 'true',
      'stderr' => 'true',
    },
    subsetting_sections => {
      'command.0' => {
        'bin'  => '"/usr/lib64/nagios/plugins/check_procs"',
        'args' => '["-w 1:1 -c 4 -C sshd"]'
      },
    }
  }

  #Check that will pass with a CRITICAL:
  #/usr/lib64/nagios/plugins/check_procs -w 1:1 -c 2 -C sshd
  ::heka::plugin { 'check_procs_critical':
    type => 'ProcessInput',
    settings => {
      'ticker_interval' => '10',
      'splitter' => '"newline_splitter"',
      'stdout' => 'true',
      'stderr' => 'true',
    },
    subsetting_sections => {
      'command.0' => {
        'bin'  => '"/usr/lib64/nagios/plugins/check_procs"',
        'args' => '["-c 1 -C sshd "]'
      },
    }
  }

  #SandboxFilter that will process the ProcessInput messages
  #and turn them into a form the DashbardOutput can display:
  ::heka::plugin { 'process_input_filter':
    type => 'SandboxFilter',
    settings => {
      'filename' => '"lua_filters/processinput_to_json_filter.lua"',
      'ticker_interval' => '1',
      'preserve_data' => 'true',
      'message_matcher' => "\"Type == 'ProcessInput'\"",
    },
  }

}