require 'rubygems'
%w{aws/s3 fileutils logger md5 base64 yaml sdbtools pstore}.each &method(:require)
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'squidward/command'

# These are the default constants used along the code to refer to the squidward folders 
CONF_PATH, SETTINGS_FILE, TEMP_PATH, LOG_FILE = "~/.squidward", ".settings", "temp", "squidward.log"

# Default module that contains the whole application
module Squidward
  # Commands container, if you can't call this a command pattern implentation, there's no such thing 
  module Command   
    class << self
      # Runs the given command and performs the proper invocation based on the user input.
      # This method is the core dispatcher for the whole application.
      def run!(command, args)
        command, method = command.gsub(/-/,'_').split(/:/)
        klass, method = eval("Squidward::Command::#{command.capitalize}"), (method or :index).to_sym

        instance = klass.new
        instance.send(method, args)
      rescue 
        puts("Unknown command. Run 'squidward help' for usage information.")
      end
    end
  end
end