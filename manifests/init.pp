# Class: play
#
# This module manages play framework applications and modules.
# The class itself installs Play 1.2.3 in /opt/play-1.2.3
#
# Actions:
#  play::module checks the availability of a Play module. It installs
#  it if not found
#  play::application starts a play application
#  play::service starts a play application as a system service
#
# Parameters:
# *version* : the Play version to install
#
# Requires:
# wget puppet module https://github.com/EslamElHusseiny/puppet-wget
# A proper java installation and JAVA_HOME set
# Sample Usage:
#  class {'play':
#    version => "2.1.4",
#    user    => "appuser"
#  }
#  play::module {"mongodb module" :
#    module  => "mongo-1.3",
#    require => [Class["play"], Class["mongodb"]]
#  }
#
#  play::module { "less module" :
#    module  => "less-0.3",
#    require => Class["play"]
#  }
#
#  play::service { "bilderverwaltung" :
#    path    => "/home/clement/demo/bilderverwaltung",
#    require => [Jdk6["Java6SDK"], Play::Module["mongodb module"]]
#  }
#
class play (
  $version, #1.2.12
  $install_path = '/usr/local',
  $user= 'root'
) {

  include wget

  $play_path = "${install_path}/activator-${version}"
  #$download_url = "http://downloads.typesafe.com/typesafe-activator/${version}/typesafe-activator-${version}-minimal.zip"
  $download_url = "http://downloads.typesafe.com/typesafe-activator/${version}/typesafe-activator-${version}.zip"

  notice("Installing Play ${version}")

  exec { 'download-play-framework':
    cwd     => $install_path,
    command => "/opt/boxen/homebrew/bin/wget -O /tmp/activator-${version}.zip  $download_url",
  }


  exec { 'mkdir.play.install.path':
    command => "/bin/mkdir -p ${install_path}",
    unless  => "/bin/bash [ -d ${install_path} ]"
  }

  exec { 'unzip-play-framework':
    cwd     => $install_path,
    command => "tar xvf /tmp/activator-${version}.zip",
    creates => "${play_path}",
    path    => ['/usr/bin'],
    #unless  => "/bin/test -d ${play_path}",
    require => [
      #Package['unzip'],
      Exec['download-play-framework'],
      Exec['mkdir.play.install.path']
    ],
  }

  #exec { 'change ownership of tmp location':
   # cwd     => $install_path,
   # command => "",   #"/usr/sbin/chown -R 775 /tmp/activator-${version}.zip",
   # require => Exec['download-play-framework']
  #}

  #exec { 'change ownership of play installation':
  # cwd     => $install_path,
  # command => "/usr/sbin/chown -R ${user}: /tmp/activator-${version}",
  # require => Exec['unzip-play-framework']
  #}

  #file { "${play_path}/activator":
   # ensure  => file,
   # owner   => $user,
   # mode    => '0755',

  #file {'/usr/bin/activator':
   # ensure  => 'link',
   # target  => "${play_path}/activator",
   # require => File["${play_path}/play"],
  #}

  exec {'adding symbolic link':
    command => "ln -sf ${play_path}/activator /opt/boxen/bin/activator",
    require => Exec['unzip-play-framework']
  }

  # Add a unversioned symlink to the play installation.
  exec { "${install_path}/activator":
    command  => "ln -sf ${play_path} ${install_path}/activator",
    require => Exec['mkdir.play.install.path', 'unzip-play-framework']
  }

  if !defined(Package['unzip']) {
    notice("on mac unzip should be installed by default... skipping unzip installation") 
    #package{ 'unzip': ensure => installed }
  }
}
