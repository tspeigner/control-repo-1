class profile::platform::baseline (
  Boolean $orch_agent  = false,
  Array   $timeservers = ['0.pool.ntp.org','1.pool.ntp.org'],
  Boolean $enable_monitoring = false,
){

  # Global
  class {'::time':
    servers => $timeservers,
  }

  class {'::profile::puppet::orch_agent':
    ensure => $orch_agent,
  }

  # add sensu client
  if $enable_monitoring {
    include ::profile::app::sensu::client
  }

  $plat = $facts.get('os.family') ? {
    #If os.family == 'windows' then $plat = 'windows', default is 'linux'
    /windows/ => 'windows',
    default   => 'linux'
  }

  $env = $facts.get('ipaddress') ? {
    # If a node has an IP in the range 10.0.24.253-255 it's in the Dev VPC
    /^10\.0\.24\.(2(5[3-5]))$/   => 'dev',
    # If a node has an IP in the range 10.0.24.243-245 it's in the UAT VPC
    /^10\.0\.24\.(2(4[3-5]))$/   => 'uat',
    # If a node has an IP in the range 10.0.24.233-235 it's in the Prod VPC
    /^10\.0\.24\.(2(3[3-5]))$/   => 'prod',
    default => fail('Environment does not exist'),
  }
# If env = dev and plat = linux == profile::platform::baseline::linux::dev
# This is interpolated in the 'include' below
notify { 'plat and env':
  message => "${plat} and ${env}"
}
include "profile::platform::baseline::${plat}::${env}"
}
