module Squidward
  module Command
    # Handles all the commands related to credentials
    class Credentials < Secured
      # Removes the stored credentials from the current configuration
      def clear(args = nil)
        new_configuration = configuration
        new_configuration[:credentials] = nil
        store_configuration(new_configuration)
      end
      
      # Stores the credentials to the current configuration
      def set(args = nil)
        # don't do anything, already handles it the parent class
      end
    end
  end
end