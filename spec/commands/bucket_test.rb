# enabling the load of files from root (on RSpec)
$LOAD_PATH.unshift(File.dirname(__FILE__) + '/../')
require 'spec_config'

describe "bucket command functionality" do
  before do 
    Squidward::Command::Bucket.any_instance.expects(:read_credentials).returns(["access_key", "secret_key"])
  end
  
  it "should inherit the Base functionality" do
    my_command = Squidward::Command::Bucket.new()
  end
  
  it "should set backup default bucket" do
    my_command = Squidward::Command::Bucket.new()
    my_command.expects(:configuration).returns({})
    my_command.expects(:store_configuration).with({:default_bucket => "backup"})
    my_command.set(["backup"])
  end
end