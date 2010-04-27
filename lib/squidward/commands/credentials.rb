module Squidward
  module Command
    # Handles all the commands related to credentials
    class Credentials < Base
      # Removes the stored credentials from the current configuration
      def clear(args = nil)
        new_configuration = configuration
        new_configuration[:credentials] = nil
        store_configuration(new_configuration)
      end
    end
  end
end