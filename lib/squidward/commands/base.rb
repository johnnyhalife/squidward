module Squidward
  module Command
    # Base command from where all the other commands inherit
    # it contains the most used methods (stout, sterror, etc) and 
    # also handles the configuration, hence AWS credentials
    class Base
      # Creates a new instance and prompts the user for the 
      # credentials if they aren't stored
      def initialize()
        unless (@credentials = read_credentials)
          @credentials = ask_for_credentials
          store_credentials(@credentials)
        end
      end
      
      # Gets the AWS Credentials from the user
      def ask_for_credentials
        puts "Enter your AWS credentials."

        print "Access Key ID: "
        user = ask

        print "Secret Access Key: "
        password = ask_for_password

        return [user, password]
      end
      
      # Turns off the standard output while writting the password
      def echo_off
        system "stty -echo"
      end
      
      # Turns on the standard output after writting the password
      def echo_on
        system "stty echo"
      end
      
      # Gets trimmed input from the user
      def ask
        gets.strip
      end

      # Gets trimmed input from the user but with echoing off
      def ask_for_password
        echo_off
        password = ask
        puts
        echo_on
        return password
      end
      
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
      
      # Reads credentials from the configuration file
      def read_credentials
        conf = self.configuration
        return nil unless conf[:credentials]
        return [conf[:credentials][:access_key], conf[:credentials][:secret_key]]
      end

      # Dumps configuration file contents to the user profile
      def store_configuration(new_configuration)
        FileUtils.mkpath(File.expand_path(CONF_PATH))
        File.open(File.expand_path(File.join(CONF_PATH, SETTINGS_FILE)), "w+") do |io|
          YAML::dump(new_configuration, io)
        end
      end
      
      # Stores the users credentials on the configuration.
      def store_credentials(credentials)
        conf = configuration
        conf[:credentials] = {}
        conf[:credentials][:access_key], conf[:credentials][:secret_key] = credentials[0], credentials[1]
        store_configuration(conf)
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