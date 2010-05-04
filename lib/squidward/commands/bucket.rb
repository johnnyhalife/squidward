module Squidward
  module Command
    # Handles all the command related to AWS S3's buckets
    class Bucket < Secured
      # Sets the destination bucket for the backups to be uploaded on S3
      def set(args)
        new_configuration = configuration
        new_configuration[:default_bucket] = args[0]
        store_configuration(new_configuration)
      end
    end
  end
end