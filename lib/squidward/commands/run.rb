module Squidward
  module Command
    # Core class of the whole application. It simply runs everything once it has been configured.
    class Run < Base
      def initialize()
        super
        aws_config = {}
        aws_config[:access_key_id], aws_config[:secret_access_key] = @credentials
        AWS::S3::Base.establish_connection!(aws_config)
      end
      
      # Runs the backup for each configured simpledb domain
      def index(args = {})
        ensure_bucket!(bucket)
        domains.each do |domain|
          internal_run(domain)
        end
      end
      
      # If the configured bucket does not exists on AWS S3 it will create it, 
      # else it will just retrieve it.
      def ensure_bucket!(bucket_name)
        begin 
           AWS::S3::Bucket.find(bucket_name) 
        rescue
          AWS::S3::Bucket.create(bucket_name) 
        end
      end
      
      # Performs a backup for a specific domain
      def internal_run(pair = {})
        domain_name, virtual_path = pair[:domain], (pair[:vpath] or "")
        return unless database.domain_exists?(pair[:domain])
        dump_file = dump_domain(domain_name)
        dump_file_md5 = Base64.encode64(compute_md5(dump_file).digest)
        upload_to = File.join(virtual_path, generate_dump_filename(domain_name))
        AWS::S3::S3Object.store("#{upload_to}.tar.gz", open(dump_file), bucket, :content_md5 => dump_file_md5)
        File.delete(dump_file)
      end

      # Dumps the domain contents to YAML file
      def dump_domain(domain_name)
        temp_folder = File.expand_path(File.join(CONF_PATH, TEMP_PATH))
        FileUtils.mkpath(temp_folder)
        temp_file = File.join(temp_folder, generate_dump_filename(domain_name))
        results = database.domain(domain_name).selection().results
        File.open(temp_file, "w+") { |io| YAML::dump(results, io) }
        `tar -czf "#{temp_file}.tar.gz" -C "#{File.dirname(temp_file)}" "#{File.basename(temp_file)}"`
        File.delete(temp_file)
        return "#{temp_file}.tar.gz"
      end
      
      # Generates a unique filename for the current domain backup
      def generate_dump_filename(domain_name)
        "#{domain_name}-#{Time.now.utc.strftime("%Y%m%d%H%M%S%Z%Y")}"
      end

      # Singleton instance of the database
      def database
        @database ||= SDBTools::Database.new(@credentials[0],  @credentials[1], :logger => self.logger)
      end
      
      # Returns every configured domain for the current user
      def domains
        return self.configuration[:domains]
      end

      # Returns the bucket configured for the current user
      def bucket
        return (self.configuration[:default_bucket] or "backup")
      end
      
      # Computes the MD5 for the uploaded file, in-case you 
      # wanna do corruption detection
      def compute_md5(filename)
        md5_digest = Digest::MD5.new
        File.open(filename, 'r') do |file|
          file.each_line do |line|
            md5_digest << line
          end
        end
        return md5_digest
      end
    end
  end
end