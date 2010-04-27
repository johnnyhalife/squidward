module Squidward
  module Command
    # Handles the echoing of the current configuration (pretty basic tough)
    class Info < Base
      # Goes thru the settings and echos their values.
      def index(args = nil)
        display("=== Current Settings")
        display("Amazon Web Services Account:  #{configuration[:credentials][:access_key]}")
        display("Amazon S3 Bucket:             #{configuration[:default_bucket]}")
        display("")
        if (configuration[:domains] and configuration[:domains].size > 0)
          display("Configured Domains:           ", false)  
          first = true
          configuration[:domains].each do |domain|
            spaces = (not first) ? " " * 30 : ""
            display(spaces + "#{domain[:domain]} is being uploaded to #{domain[:vpath] or "<bucket_root>"}")
            first = false
          end
        else
          display("Configured Domains:           You currently have no domains configuration for backup")
        end
        display("")
      end
    end
  end
end