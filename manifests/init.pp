# == Class: stackdriver
#
# Manage stackdriver
#
class stackdriver (
  $manage_repo = true,
  $baseurl     = undef,
  $gpgkey      = 'https://app.stackdriver.com/RPM-GPG-KEY-stackdriver',
) {

  if $baseurl == undef {
    $baseurl_real = "http://repo.stackdriver.com/repo/el${::operatingsystemmajrelease}/\$basearch/"
  } else {
    $baseurl_real = $baseurl
  }

  if is_string($manage_repo) == true {
    $manage_repo_real = str2bool($manage_repo)
  } else {
    $manage_repo_real = $manage_repo
  }

  validate_bool($manage_repo_real)
  validate_string($baseurl_real)
  validate_string($gpgkey)

  if $manage_repo_real == true {
    yumrepo { 'stackdriver':
      ensure   => 'present',
      descr    => 'Stackdriver Agent Repository',
      baseurl  => $baseurl_real,
      enabled  => true,
      gpgcheck => true,
      gpgkey   => $gpgkey,
      before   => [
        Package['stackdriver-agent'],
        Package['stackdriver-extractor'],
      ],
    }
  }

  package { 'stackdriver-agent':
    ensure => 'present',
  }

  package { 'stackdriver-extractor':
    ensure => 'present',
  }

  file { '/etc/sysconfig/stackdriver':
    ensure  => 'file',
    content => template('stackdriver/sysconfig.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => Package['stackdriver-agent'],
    notify  => Service['stackdriver-agent'],
  }

  service { 'stackdriver-agent':
    ensure  => 'running',
    enable  => true,
    require => Package['stackdriver-agent'],
  }

  service { 'stackdriver-extractor':
    ensure  => 'stopped',
    enable  => false,
    require => Package['stackdriver-extractor'],
  }
}
