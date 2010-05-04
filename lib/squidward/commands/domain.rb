module Squidward
  module Command
    # Handles everything related to AWS SimpleDB Domains for Backup
    class Domain < Secured
      # Configures a SimpleDB domain for backup. When given the second parameter is 
      # the virtual path inside the bucket to be stored.
      def backup(args)
        domain, vpath = args
        conf = self.configuration
        conf[:domains] = (conf[:domains] or []) + [{:domain => domain, :vpath => vpath}]
        store_configuration(conf)
      end
      
      # Removes a SimpleDB domain already being backed up from the current user profile
      # so it doesn't run anymore.      
      def remove(args)
        domain, vpath = args
        conf = self.configuration
        conf[:domains] = conf[:domains].reject{|d| d[:domain].downcase.strip == domain.downcase.strip}
        store_configuration(conf)
      end
    end
  end
end