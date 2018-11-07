require 'shellwords'
#
# helm_plugin_global_flags.rb
#
module Puppet::Parser::Functions
  newfunction(:helm_plugin_global_flags, type: :rvalue) do |args|
    opts = args[0] || {}
    flags = []
    if opts['kube_context'].to_s != 'undef'
      flags << "--kube-context '#{opts['kube_context']}'"
    end
    if opts['tiller_connection_timeout'].to_s != 'undef'
      flags << "--tiller-connection-timeout '#{opts['tiller_connection_timeout']}'"
    end
    if opts['tiller_namespace'].to_s != 'undef'
      flags << "--tiller-namespace '#{opts['tiller_namespace']}'"
    end
    flags << '--debug' if opts['debug']
    flags << "--home '#{opts['home']}'" if opts['home'].to_s != 'undef'
    flags << "--host '#{opts['host']}'" if opts['host'].to_s != 'undef'
    flags << opts['plugin']

    flags.flatten.join(' ')
  end
end
