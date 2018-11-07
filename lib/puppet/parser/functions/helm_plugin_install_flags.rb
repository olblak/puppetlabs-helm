require 'shellwords'
#
# helm_plugin_install_flags.rb
#
module Puppet::Parser::Functions
  newfunction(:helm_plugin_install_flags, type: :rvalue) do |args|
    opts = args[0] || {}
    flags = []

    flags << opts['plugin']

    case opts['version'].to_s
    when 'undef' then flags << '--version master'
    else flags << "--version '#{opts['version']}'"
    end

    flags.flatten.join(' ')
  end
end
