class profile::heka {

  class { '::heka':
  }


  ::heka::plugin::input::tcpinput { 'tcpinput1':
    refresh_heka_service => true,
    address => "${::ipaddress_lo}:5565"
  }

  ::heka::plugin::input::tcpinput { 'tcpinput2':
    refresh_heka_service => true,
    address => "${::ipaddress_lo}:5566"
  }

  ::heka::plugin::input::tcpinput { 'tcpinput3':
    refresh_heka_service => true,
    address => "${::ipaddress_lo}:5567"
  }

  ::heka::plugin::input::udpinput { 'udpinput1':
    refresh_heka_service => true,
    address => "${::ipaddress_lo}:4880"
  }

  ::heka::plugin { 'tcpinput4':
    refresh_heka_service => true,
    type => 'TcpInput',
    settings => {
      'address' => '"127.0.0.1:5568"',
      'parser_type' => '"token"',
    },
  }

  ::heka::plugin { 'dashboard1':
    type => 'DashboardOutput',
    settings => {
      'address' => '"10.0.1.120:4352"',
      'ticker_interval' => 6,
    },
  }

  ::heka::plugin { 'dashboard2':
    type => 'DashboardOutput',
    settings => {
      'address' => '"10.0.1.120:4353"',
      'ticker_interval' => 6,
    },
  }

  ::heka::plugin { 'dashboard3':
    type => 'DashboardOutput',
    settings => {
      'address' => '"10.0.1.120:4354"',
      'ticker_interval' => 6,
    },
  }



}