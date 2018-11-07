# Class: helm::plugin
# ===========================
#
# A definition to install Helm Plugin

# Cfr. README for parameter documentation

define helm::plugin (
  Boolean          $debug                     = $helm::debug,
  String           $ensure                    = present,
  Optional[Array]  $env                       = $helm::env,
  Optional[String] $home                      = $helm::home,
  Optional[String] $helm_home                 = $helm::helm_home,
  Optional[String] $host                      = $helm::host,
  Optional[String] $kube_context              = $helm::kube_context,
  Array            $path                      = $helm::path,
  String           $plugin                    = $title,
  Optional[String] $tiller_connection_timeout = undef,
  String           $tiller_namespace          = $helm::tiller_namespace,
  Optional[String] $url                       = $helm::diff_url,
  Optional[String] $version                   = $helm::version
) {

  if ($plugin == undef) {
    fail(translate("\nYou must specify a plugin name or url"))
  }

  if ($url == undef and $ensure == present ) {
    fail(translate("\nMissing url plugin to install ${plugin}"))
  }

  $helm_plugin_global_flags = helm_plugin_global_flags({
    ensure => $ensure,
    tiller_namespace          => $tiller_namespace,
    tiller_connection_timeout => $tiller_connection_timeout,
    kube_context              => $kube_context,
    host                      => $host,
    home                      => $helm_home,
    debug                     => $debug,
  })

  case $ensure {
    present: {
      exec { "Remove helm plugin: ${plugin}:${version}":
        command     => "helm plugin remove ${plugin} ${helm_plugin_global_flags}",
        environment => $env,
        path        => $path,
        timeout     => 0,
        tries       => 10,
        try_sleep   => 10,
        unless      => @("CMD"/L$)
          helm plugin list ${helm_plugin_global_flags} | \
          grep -E '^${plugin} *'| \
          awk 'END {if(NF!=0 && \$1 == "${plugin}" && \$2 !~ /^${version}.*/) exit 1; exit 0}'
          | CMD
      }

      $helm_plugin_install_flags = helm_plugin_install_flags({version => $version})
      $exec = "Install helm plugin: ${plugin}"
      $exec_plugin = "helm plugin install ${helm_plugin_global_flags} ${url} ${helm_plugin_install_flags}"
      $unless_chart = @("CMD"/L$)
        helm plugin list ${helm_plugin_global_flags} | \
        grep -E '^${plugin} *'| \
        awk 'END {if(NF==0 || \$1 != "${plugin}") exit 1; exit 0}'
        | CMD
    }
    absent: {
      $exec = "Remove helm plugin: ${plugin}"
      $exec_plugin = "helm plugin remove ${plugin} ${helm_plugin_global_flags}"
      $unless_chart = @("CMD"/L$)
        helm plugin list ${helm_plugin_global_flags} | \
        grep -E '^${plugin} *'| \
        awk 'END {if(NF!=0 && \$1 == "${plugin}") exit 1; exit 0}'
        | CMD
    }
    default: {
      fail(translate("\nEnsure plugin ${plugin} is only 'present' or 'absent'"))
    }
  }

  exec { $exec:
    command     => $exec_plugin,
    environment => $env,
    path        => $path,
    timeout     => 0,
    tries       => 10,
    try_sleep   => 10,
    unless      => $unless_chart,
  }
}
