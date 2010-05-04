module Squidward
  module Command
    # Base command from where all the other commands inherit
    # it contains the most used methods (stout, sterror, etc) and 
    # also handles the configuration, hence AWS credentials
    class Base            
      # Reads the configuration from the profile, if the reload parameter is set to true, it will 
      # read it again, if not it will just return what it's already in-memory.
      def configuration(reload = false)
        # if the user asks not to reload we should send what we've got except we don't got anything
        return @configuration if (@configuration and not reload)
        path = File.expand_path File.join(CONF_PATH, SETTINGS_FILE)
        # if the configuration file isn't created yet it should create it
        return {} unless File.exists?(path)
        @configuration = YAML.load_file(path)
      end
      
      # Dumps configuration file contents to the user profile
      def store_configuration(new_configuration)
        FileUtils.mkpath(File.expand_path(CONF_PATH))
        File.open(File.expand_path(File.join(CONF_PATH, SETTINGS_FILE)), "w+") do |io|
          YAML::dump(new_configuration, io)
        end
      end
      
      # Nice and clean way of echoing
      def display(msg, newline=true)
        if newline
          puts(msg)
        else
          print(msg)
          STDOUT.flush
        end
      end
      
      # Logger singleton
      def logger
        return @logger if @logger
        @logger = Logger.new(File.expand_path(File.join(CONF_PATH, LOG_FILE)))
        @logger.level = Logger::INFO
        @logger.formatter = Proc.new {|s, t, n, msg| "[#{t}] [#{s}] #{msg}\n"}
        @logger
      end
    end
  end
end