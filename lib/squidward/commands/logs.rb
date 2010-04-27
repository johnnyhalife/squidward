module Squidward
  module Command
    # Handles the information related to the log being genereated by the application
    class Logs < Base
      # Echoes to the stdout the latest 25 lines of the log
      def index(args = nil)
        system "tail -n 25 #{File.expand_path(File.join(CONF_PATH, LOG_FILE))}"
      end
    end
  end
end