# enabling the load of files from root (on RSpec)
$LOAD_PATH.unshift(File.dirname(__FILE__) + '/../')
require 'spec_config'

describe "runner command functionality" do
  before do 
    Squidward::Command::Run.any_instance.expects(:read_credentials).returns(["access_key", "secret_key"])
    AWS::S3::Base.expects(:establish_connection!).with(:access_key_id => "access_key", :secret_access_key => "secret_key")
  end
  
  it "should inherit the Base functionality" do
    my_command = Squidward::Command::Run.new()
  end
  
  it "should return services to run from the configuration" do
    configuration = {:domains => [{:domain => "domain1", :vpath => "path2"}, 
                                 {:domain => "domain2", :vpath => "path2"}]}

     my_command = Squidward::Command::Run.new() 
     my_command.expects(:configuration).returns(configuration)
     my_command.domains.should == configuration[:domains]
  end
  
  it "should return services to run from the configuration" do
    configuration = {:default_bucket => "backup"}
    my_command = Squidward::Command::Run.new() 
    my_command.expects(:configuration).returns(configuration)
    my_command.bucket.should == configuration[:default_bucket]
  end
  
  it "should return services to run from the configuration" do
     my_command = Squidward::Command::Run.new() 
     my_command.expects(:configuration).returns({})
     my_command.bucket.should == "backup"
  end
  
  it "should run the backup for each domain (and ensure the destination bucket exists)" do
    my_command = Squidward::Command::Run.new()
    my_command.expects(:ensure_bucket!).returns("backup.squidward.full").once    
    my_command.expects(:domains).returns([{:domain => "domain1", :vpath => "bucket1"}])
    my_command.expects(:internal_run).with({:domain => "domain1", :vpath => "bucket1"})
    my_command.index
  end

  it "should run the backup for each domain (and avoide creating the destination bucket when it exists)" do
    my_command = Squidward::Command::Run.new()
    my_command.expects(:bucket).returns("backup.squidward.full")
    my_command.expects(:ensure_bucket!).with("backup.squidward.full")
    my_command.expects(:domains).returns([{:domain => "domain1", :vpath => "bucket1"}])
    my_command.expects(:internal_run).with({:domain => "domain1", :vpath => "bucket1"})
    my_command.index
  end

  it "should dump a domain and return the file path to the dump result" do
    FileUtils.expects(:mkpath).with(File.expand_path(File.join(CONF_PATH, TEMP_PATH))).returns("temp-path")
    dump_file = File.expand_path(File.join(CONF_PATH, TEMP_PATH, "dump"))
    
    my_command = Squidward::Command::Run.new()
    my_command.expects(:generate_dump_filename).returns("dump")
    
    (mock_selection = mock).expects(:results).returns([])
    (mock_domain = mock).expects(:selection).returns(mock_selection)    
    (mock_db = mock).expects(:domain).with("custom-domain").returns(mock_domain)
    my_command.expects(:database).returns(mock_db)
    
    File.expects(:open).with(dump_file, "w+")
    File.expects(:delete).with(dump_file)
    
    my_command.expects(:`).with("tar -czf \"#{dump_file}.tar.gz\" -C \"#{File.dirname(dump_file)}\" \"#{File.basename(dump_file)}\"")  
    my_command.dump_domain("custom-domain").should == "#{dump_file}.tar.gz"
  end

  it "should generate the filename for the dumped file" do
    now = Time.now
    Time.expects(:now).returns(now).twice
    my_command = Squidward::Command::Run.new()
    my_command.generate_dump_filename("my-domain").should == "my-domain-#{Time.now.utc.strftime("%Y%m%d%H%M%S%Z%Y")}"
  end
  
  it "should do anything if domain does not exist" do
    my_command = Squidward::Command::Run.new()
    (mock_db = mock).expects(:domain_exists?).with("domain1").returns(false)
    my_command.expects(:database).returns(mock_db)
    my_command.internal_run(:domain => "domain1", :vpath => "/sdb/")
  end

  it "should do full blown backup of a single domain when it exists" do
    my_command = Squidward::Command::Run.new()
    my_command.expects(:bucket).returns("my_bucket")
    
    my_command.expects(:generate_dump_filename).with("domain").returns("dump")
    
    # the domain already exists
    (mock_db = mock).expects(:domain_exists?).with("domain").returns(true)
    my_command.expects(:database).returns(mock_db)
    
    # ask the library to dump the files
    my_command.expects(:dump_domain).with("domain").returns("mock/path/to/file.tar.gz")
    
    # generate md5-base64 for the file
    (mock_digest = mock).expects(:digest).returns("digest")
    my_command.expects(:compute_md5).with("mock/path/to/file.tar.gz").returns(mock_digest)
    Base64.expects(:encode64).with("digest").returns("base64digest")
    
    # mock the file opening
    my_command.expects(:open).with("mock/path/to/file.tar.gz").returns("contents")
    
    AWS::S3::S3Object.expects(:store).with("/sdb/dump.tar.gz", "contents", "my_bucket", :content_md5 => "base64digest")
    
    File.expects(:delete).with("mock/path/to/file.tar.gz")
    my_command.internal_run(:domain => "domain", :vpath => "/sdb/")
  end

  it "should hold a singleton instance of the database" do
   (mock_logger = mock).expects(:info)
   Squidward::Command::Run.any_instance.expects(:logger).returns(mock_logger)
   my_command = Squidward::Command::Run.new()
   my_command.database.nil?.should == false 
  end
  
  it "should look up for the bucket when calling ensure if it exists" do
    my_command = Squidward::Command::Run.new()
    AWS::S3::Bucket.expects(:find).with("my_bucket").returns(mock)
    my_command.ensure_bucket!("my_bucket").nil?.should == false
  end
  
  it "should create the bucket when it does not exist" do
    my_command = Squidward::Command::Run.new()
    AWS::S3::Bucket.expects(:find).with("my_bucket").raises(StandardError)
    AWS::S3::Bucket.expects(:create).with("my_bucket").returns(mock)
    my_command.ensure_bucket!("my_bucket").nil?.should == false
  end
end