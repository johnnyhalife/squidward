module Squidward
  module Command
    # Gem Versioning Helper and also displays current version to the user
    class Version < Base
      GEM_VERSION = "0.5"
      
      # Displays current gem version to the user
      def index(args = nil)
        display("squidward-#{GEM_VERSION}")
      end
    end
  end
end
    
  