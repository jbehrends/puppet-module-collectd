class collectd(
  $fqdnlookup   = 'true',
  $purge        = undef,
  $recurse      = undef,
  $purge_config = false,
  $interval     = 10,
  $timeout      = 2,
) {
  include collectd::params

  $plugin_conf_dir = $collectd::params::plugin_conf_dir

  package { 'collectd':
    ensure   => installed,
    name     => $collectd::params::package,
    provider => $collectd::params::provider,
    before   => File['collectd.conf'],
  }

  file { 'collectd.d':
    ensure  => directory,
    name    => $collectd::params::plugin_conf_dir,
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
    purge   => $purge,
    recurse => $recurse,
  }

  $conf_content = $purge_config ? {
    false => undef,
    true  => template('collectd/collectd.conf.erb'),
  }

  file { 'collectd.conf':
    path    => $collectd::params::config_file,
    content => $conf_content,
    notify  => Service['collectd'],
  }

  if $purge_config != true {
    # Include conf_d directory
    file_line { 'include_conf_d':
      line    => "Include \"${collectd::params::plugin_conf_dir}/\"",
      path    => $collectd::params::config_file,
      notify  => Service['collectd'],
    }
  }

  service { 'collectd':
    ensure    => running,
    name      => $collectd::params::service_name,
    enable    => true,
    require   => Package['collectd'],
  }
}
