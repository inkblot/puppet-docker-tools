# ex: syntax=puppet si sw=2 ts=2 et
class docker_tools::machine (
  $version,
  $base_url      = 'https://github.com/docker/machine/releases/download',
  $target_dir    = '/usr/local/bin',
  $tmp_dir       = '/tmp',
  $checksum_type = undef,
  $checksum      = undef
) {

  case $::architecture {
    'amd64': { $_arch = 'x86_64' }
    default: { $_arch = $::architecture }
  }

  $bin_filename = "docker-machine-${::kernel}-${_arch}"
  archive { "${tmp_dir}/${bin_filename}":
    ensure          => present,
    source          => "${base_url}/${version}/${bin_filename}",
    checksum_verify => true,
    checksum        => $checksum,
    checksum_type   => $checksum_type,
    creates         => "${target_dir}/docker-machine-${version}",
  }

  exec { '/usr/local/bin/docker-machine-version':
    command     => "mv ${tmp_dir}/${bin_filename} ${target_dir}/docker-machine-${version}",
    subscribe   => Archive["${tmp_dir}/${bin_filename}"],
    path        => ['/bin'],
    refreshonly => true,
  }

  file { "${target_dir}/docker-machine":
    ensure => link,
    target => "${target_dir}/docker-machine-${version}",
  }
}
