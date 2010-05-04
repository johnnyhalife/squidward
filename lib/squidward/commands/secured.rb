module Squidward
  module Command
    # Base command from where all the commands 
    # are secured and need credentials, hence it handles AWS credentials
    class Secured < Base
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
            
      # Reads credentials from the configuration file
      def read_credentials
        conf = self.configuration
        return nil unless conf[:credentials]
        return [conf[:credentials][:access_key], conf[:credentials][:secret_key]]
      end
      
      # Stores the users credentials on the configuration.
      def store_credentials(credentials)
        conf = configuration
        conf[:credentials] = {}
        conf[:credentials][:access_key], conf[:credentials][:secret_key] = credentials[0], credentials[1]
        store_configuration(conf)
      end
    end
  end
end